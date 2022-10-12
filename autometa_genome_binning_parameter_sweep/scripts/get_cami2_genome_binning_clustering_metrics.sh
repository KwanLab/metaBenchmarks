#!/usr/bin/env bash
#SBATCH --partition=queue
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks
#SBATCH --cpus-per-task=1
#SBATCH --error=%J.cami2_genome_binning_clustering_metrics.err
#SBATCH --output=%J.cami2_genome_binning_clustering_metrics.out



# function join_by {
#     local d=${1-} f=${2-}
#     if shift 2; then
#         printf %s "$f" "${@/#/$d}"
#     fi
# }


## We will evaluate clustering results for all datasets...

# Input: reference_binning, cami2_repo_binning_dir, autometa_binning_predictions_dir, autometa_binning_ldm_predictions_dir
get_clustering_benchmarks () {
    # get_clustering_benchmarks $reference_binning $cami2_binning_results $autometa_binning_results $autometa_binning_ldm_results
    sample_name=$(basename ${1/.binning/})
    # marine GSA: gsa_pooled_mapping_short.binning
    # marine MA: marine_megahit.binning
    # strmg GSA: gsa_pooled_mapping.binning
    # strmg MA: strain_madness_megahit.binning

    reference_reformatted="${outdir}/${sample_name}.binning.tsv"
    wide_output="${outdir}/${sample_name}.clustering_benchmarks_wide.tsv.gz"
    long_output="${outdir}/${sample_name}.clustering_benchmarks_long.tsv.gz"
    # Retrieve all .binning.tsv files for use in entrypoint
    cami2_predictions=($(ls $2/*.binning))
    echo "${#cami2_predictions[@]} CAMI2 genome binning predictions found for $(basename $2)"
    autometa_binning_predictions=($(find $3 -name "*.binning.tsv"))
    echo "${#autometa_binning_predictions[@]} autometa-binning genome binning predictions found for $(basename $3)"
    autometa_binning_ldm_predictions=($(find $4 -name "*.binning.tsv"))
    echo "${#autometa_binning_ldm_predictions[@]} autometa-binning-ldm genome binning predictions found for $(basename $4)"
    predictions=("${cami2_predictions[@]}" "${autometa_binning_predictions[@]}" "${autometa_binning_ldm_predictions[@]}")
    echo "${#predictions[@]} total genome binning predictions found for ${sample_name}"

    # Pass reference table to python...
    export REF_IN=$1
    export CAMI2_BINNING_DIR=$2
    export REF_OUT=${reference_reformatted}
    export AUTOMETA_BINNING_DIR=$3
    export AUTOMETA_BINNING_LDM_DIR=$4
    export WIDE_OUTPUT=${wide_output}
    export LONG_OUTPUT=${long_output}
    export OUTDIR=${outdir}
    export SAMPLE_ID=$sample_name
    python -c """
import os
import glob
import pandas as pd
from autometa.validation.benchmark import evaluate_clustering


ref_filepath = os.environ['REF_IN']
ref_outfpath = os.environ['REF_OUT']
cami2_binning_dirpath = os.environ['CAMI2_BINNING_DIR']
autometa_binning_dirpath = os.environ['AUTOMETA_BINNING_DIR']
autometa_binning_ldm_dirpath = os.environ['AUTOMETA_BINNING_LDM_DIR']
output_wide_fpath = os.environ['WIDE_OUTPUT']
output_long_fpath = os.environ['LONG_OUTPUT']
sample_id = os.environ['SAMPLE_ID']
outdir = os.environ.get('OUTDIR', os.path.abspath('.'))
print(f'outdir: {outdir}')
mag_counts_fpath = os.path.join(outdir, f'{sample_id}_mag_counts.tsv.gz')

# sample_id -> sample_name
sample_names = {
    'gsa_pooled_mapping':'strmgCAMI2_short_read_pooled_gold_standard_assembly',
    'gsa_pooled_mapping_short':'marmgCAMI2_short_read_pooled_gold_standard_assembly',
    'marine_megahit':'marmgCAMI2_short_read_pooled_megahit_assembly',
    'strain_madness_megahit':'strmgCAMI2_short_read_pooled_megahit_assembly',
}

## Convert reference to autometa-benchmark format (i.e. contig\treference_genome\ttaxid\tlength or contig\treference_genome\tlength)
df = pd.read_table(
    ref_filepath,
    comment='@',
    header=None,
)

names = ['contig','reference_genome','taxid','length'] if df.shape[1] == 4 else ['contig','reference_genome','length']
columns = {i:name for i,name in enumerate(names)}
df = df.rename(columns=columns)
df.to_csv(ref_outfpath, sep='\t', index=False, header=True)
print(f'Wrote reformatted reference to {ref_outfpath}')

## Convert CAMI2 results to autometa-benchmark format (i.e. contig\tcluster)

fpaths = glob.glob(os.path.join(cami2_binning_dirpath, '*.binning'))
for fp in fpaths:
    out = fp.replace('.binning','.binning.tsv')
    if os.path.exists(out):
        continue
    # @@SEQUENCEID    BINID
    df = pd.read_table(
        fp,
        comment='@',
        header=None,
        names=['contig','cluster']
    )
    df.to_csv(out, sep='\t', index=False, header=True)

## Collect all predictions
predictions = []
for dirpath in [cami2_binning_dirpath, autometa_binning_dirpath, autometa_binning_ldm_dirpath]:
    fpaths = glob.glob(os.path.join(dirpath, '*.binning.tsv'))
    predictions += fpaths

## Get binning counts
print(f'Evaluating MAG Counts for {len(predictions):,} predictions')
mag_counts = []
for prediction in predictions:
    df = pd.read_table(prediction)
    mag_count = df.dropna().cluster.nunique()
    binner = os.path.basename(prediction)
    mag_counts.append({'MAG Count':mag_count, 'binner':binner})

mag_counts_df = pd.DataFrame(mag_counts)
mag_counts_df['sample_id'] = sample_id
mag_counts_df['sample_name'] = sample_names.get(sample_id)
mag_counts_df.to_csv(mag_counts_fpath, sep='\t', index=False, header=True)
print(f'Wrote counts to {mag_counts_fpath}')
## Perform clustering evaluation
print(f'Evaluating clustering on {len(predictions):,} predictions')
df = evaluate_clustering(
    predictions=predictions,
    reference=ref_outfpath,
    average_method='max',
)
dff = df.stack()
dff.index.name = ('dataset', 'metric')
dff.name = 'score'
dff = (
    dff.to_frame()
    .reset_index(level=1)
    .rename(columns={'level_1': 'metric'})
)
dff.to_csv(output_long_fpath, sep='\t', index=True, header=True)

df.to_csv(output_wide_fpath, sep='\t', index=True, header=True)
print(f'Wrote {df.shape[0]} datasets metrics to {output_wide_fpath}')
"""
    # Equivalent to:
    # autometa-benchmark \
    #     --benchmark clustering \
    #     --predictions ${predictions[@]} \
    #     --reference $reference_reformatted \
    #     --output-wide $wide_output \
    #     --output-long $long_output

}

## INPUTS & OUTPUTS

outdir="/media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/data/cami2_genome_binning_clustering_metrics"

if [ ! -d $outdir ];then
    mkdir -p $outdir
fi

# First perform transfer_binning_results_from_chtc_to_deepthought.sh
# /media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/scripts/transfer_binning_results_from_chtc_to_deepthought.sh

CAMI2_RESULTS_REPO="/media/BRIANDATA4/second_challenge_evaluation"

# Strain Madness GSA
reference_binning="${CAMI2_RESULTS_REPO}/binning/genome_binning/strain_madness_dataset/data/ground_truth/gsa_pooled_mapping.binning"
cami2_binning_results="${CAMI2_RESULTS_REPO}/binning/genome_binning/strain_madness_dataset/data/short_read_pooled_gold_standard_assembly"
autometa_binning_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/strmgCAMI2_short_read_pooled_gold_standard_assembly/autometa_binning"
autometa_binning_ldm_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/strmgCAMI2_short_read_pooled_gold_standard_assembly/autometa_binning_ldm"

# NOTE: Glob search string: ${autometa_binning_results}/*.binning.tsv
get_clustering_benchmarks $reference_binning $cami2_binning_results $autometa_binning_results $autometa_binning_ldm_results

# Strain Madness MA:
reference_binning="${CAMI2_RESULTS_REPO}/binning/genome_binning/strain_madness_dataset/data/ground_truth/strain_madness_megahit.binning"
cami2_binning_results="${CAMI2_RESULTS_REPO}/binning/genome_binning/strain_madness_dataset/data/short_read_pooled_megahit_assembly"
autometa_binning_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/strmgCAMI2_short_read_pooled_megahit_assembly/autometa_binning"
autometa_binning_ldm_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/strmgCAMI2_short_read_pooled_megahit_assembly/autometa_binning_ldm"
get_clustering_benchmarks $reference_binning $cami2_binning_results $autometa_binning_results $autometa_binning_ldm_results

# Marine GSA:
reference_binning="${CAMI2_RESULTS_REPO}/binning/genome_binning/marine_dataset/data/ground_truth/gsa_pooled_mapping_short.binning"
cami2_binning_results="${CAMI2_RESULTS_REPO}/binning/genome_binning/marine_dataset/data/short_read_pooled_gold_standard_assembly"
autometa_binning_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/marmgCAMI2_short_read_pooled_gold_standard_assembly/autometa_binning"
autometa_binning_ldm_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/marmgCAMI2_short_read_pooled_gold_standard_assembly/autometa_binning_ldm"
get_clustering_benchmarks $reference_binning $cami2_binning_results $autometa_binning_results $autometa_binning_ldm_results

# Marine MA:
reference_binning="${CAMI2_RESULTS_REPO}/binning/genome_binning/marine_dataset/data/ground_truth/marine_megahit.binning"
cami2_binning_results="${CAMI2_RESULTS_REPO}/binning/genome_binning/marine_dataset/data/short_read_pooled_megahit_assembly"
autometa_binning_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/marmgCAMI2_short_read_pooled_megahit_assembly/autometa_binning"
autometa_binning_ldm_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/marmgCAMI2_short_read_pooled_megahit_assembly/autometa_binning_ldm"
get_clustering_benchmarks $reference_binning $cami2_binning_results $autometa_binning_results $autometa_binning_ldm_results


CAMI2_GENOME_BINNING_LABELS="/media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/data/cami2_genome_binning_labels.tsv"
# Concatenate all datasets clustering benchmarks
# export CAMI2_RESULTS_REPO=$CAMI2_RESULTS_REPO
export CAMI2_GENOME_BINNING_LABELS=${CAMI2_GENOME_BINNING_LABELS}
export OUTDIR=$outdir
python -c """
import os
import glob
import pandas as pd

outdir = os.environ.get('OUTDIR')
# cami_repo = os.environ.get('CAMI2_RESULTS_REPO')
cami2_genome_binning_labels_fpath = os.environ.get('CAMI2_GENOME_BINNING_LABELS')

# Setup dicts for converting sample_id to truncated name
env = {'ma': 'marine', 'st': 'strain madness'}
asm = {'gold': 'GSA', 'megahit': 'MA'}
delimiter = '_'

# Read in CAMI2 genome binning labels for conversion of sample_id to sample_name
labels_df = pd.read_table(cami2_genome_binning_labels_fpath, comment='#', index_col='filename')
# header --> label   filename        repo_path       sample_id
# MetaBAT 2.13-33 (A1)    sleepy_ptolemy_4.binning        binning/genome_binning/marine_dataset/data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_4.binning    marmgCAMI2_short_read_pooled_gold_standard_assembly

labels_df.index = labels_df.index.map(lambda x: f'{x}.tsv')
labels_df['sample_name'] = labels_df.sample_id.map(lambda x: f'{env.get(x.split(delimiter)[0][:2], x)} ({asm.get(x.split(delimiter)[4], x)})')

# Concatenate clustering benchmarks and retrieve sample_name from dataset name
print(f'Searching {outdir} for *.clustering_benchmarks_wide.tsv.gz')
# Concatenate and write wide table
df = pd.concat(pd.read_table(fp) for fp in glob.glob(os.path.join(outdir, '*.clustering_benchmarks_wide.tsv.gz'))).set_index('dataset')
## Add sample_id to dataframe
df = df.join(labels_df)
df.loc[df.sample_name.isna(), 'sample_name'] = df.loc[df.sample_name.isna()].index.map(lambda x: f'{env.get(x.split(delimiter)[0][:2], x)} ({asm.get(x.split(delimiter)[4], x)})')
outfpath = os.path.join(outdir, 'cami2_clustering_benchmarks_wide.tsv.gz')
df.to_csv(outfpath, sep='\t', index=True, header=True)

print('Genome binning results by sample:')
print(df.sample_name.value_counts())

### ***UNUSED BEGIN***: Formatting of CAMI2 repo genome binning results
# cami_genome_binning_fpaths = glob.glob(os.path.join(cami_repo, 'binning/genome_binning/*_dataset/data/*_assembly/*.binning'))
# [pd.read_table(fpath, comment='@', header=None, names=['', '', '']) for fpath in cami_genome_binning_fpaths]
# names = ['contig','reference_genome','taxid','length'] if df.shape[1] == 4 else ['contig','reference_genome','length']
# columns = {i:name for i,name in enumerate(names)}
# df = df.rename(columns=columns)
# df.to_csv(ref_outfpath, sep='\t', index=False, header=True)

# binning/genome_binning/strain_madness_dataset/data/short_read_pooled_megahit_assembly/clever_bohr_1.binning
# binning/genome_binning/strain_madness_dataset/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_17.binning
# binning/genome_binning/plant_associated_dataset/data/short_read_pooled_gold_standard_assembly/focused_poincare_1.binning
# binning/genome_binning/marine_dataset/data/short_read_pooled_megahit_assembly/furious_ardinghelli_6.binning
# binning/genome_binning/marine_dataset/data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_4x.binning
### ***UNUSED BEGIN***: Formatting of CAMI2 repo genome binning results


### LONG table
# Concatenate clustering benchmarks and retrieve sample_name from dataset name
# /media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/data/cami2_genome_binning_clustering_metrics/gsa_pooled_mapping_short.strains.clustering_benchmarks_long.tsv.gz
# gsa_pooled_mapping_short.strains.clustering_benchmarks_long.tsv.gz
print(f'Searching {outdir} for *.clustering_benchmarks_long.tsv.gz')
df = pd.concat(pd.read_table(fp) for fp in glob.glob(os.path.join(outdir, '*.clustering_benchmarks_long.tsv.gz'))).set_index('dataset')
## Add sample_name to dataframe
df = df.join(labels_df)
df.loc[df.sample_name.isna(), 'sample_name'] = df.loc[df.sample_name.isna()].index.map(lambda x: f'{env.get(x.split(delimiter)[0][:2], x)} ({asm.get(x.split(delimiter)[4], x)})')
# Now write out concatenated long table
outfpath = os.path.join(outdir, 'cami2_clustering_benchmarks_long.tsv.gz')
df.index.name = 'dataset'
df.to_csv(outfpath, sep='\t', index=True, header=True)


## Concatenate mag counts
mag_counts_df = pd.concat([pd.read_table(fp) for fp in glob.glob(os.path.join(outdir, '*_mag_counts.tsv.gz'))])
mag_counts_outfpath = os.path.join(outdir, 'mag_counts.tsv.gz')
mag_counts_df.to_csv(mag_counts_outfpath, sep='\t', index=False, header=True)
"""

echo "Wrote ${outdir}/cami2_clustering_benchmarks_wide.tsv.gz"
echo "Wrote ${outdir}/cami2_clustering_benchmarks_long.tsv.gz"
echo "Wrote ${outdir}/mag_counts.tsv.gz"
