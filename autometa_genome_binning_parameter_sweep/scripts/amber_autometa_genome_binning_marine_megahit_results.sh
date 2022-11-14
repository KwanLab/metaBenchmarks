#!/usr/bin/env bash
#SBATCH --partition=queue
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks
#SBATCH --cpus-per-task=1
#SBATCH --error=logs/%J.amber_marmgCAMI2_megahit.err
#SBATCH --output=logs/%J.amber_marmgCAMI2_megahit.out


# Previous Genome Binning submissions found in:
# https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/genome_binning/marine_dataset/data/short_read_pooled_megahit_assembly

# The following was the command used for the CAMI2 paper:
# From -> https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/genome_binning/marine_dataset#amber-command-for-the-binning-of-the-megahit-assembly

# amber.py -g data/ground_truth/marine_megahit.binning \
    # data/short_read_pooled_megahit_assembly/sleepy_ptolemy_10.binning \
    # data/short_read_pooled_megahit_assembly/sleepy_ptolemy_11.binning \
    # data/short_read_pooled_megahit_assembly/metabat0.25.4-veryspecific_marine_megahit.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_4.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_5.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_11.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_6.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_14.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_19.binning \
    # data/short_read_pooled_megahit_assembly/furious_ardinghelli_10.binning \
    # data/short_read_pooled_megahit_assembly/autometa_marine_megahit_l2000.binning \
    # data/short_read_pooled_megahit_assembly/clever_bohr_0.binning \
    # data/short_read_pooled_megahit_assembly/stoic_torvalds_0.binning \
    # data/short_read_pooled_megahit_assembly/stoic_torvalds_1.binning \
    # data/short_read_pooled_megahit_assembly/maxbin2.2.7_marine_megahit.binning \
    # data/short_read_pooled_megahit_assembly/maxbin2.0.2_marine_megahit.binning \
    # data/short_read_pooled_megahit_assembly/concoct1.1.0_marine_megahit.binning \
    # data/short_read_pooled_megahit_assembly/concoct0.4.1_marine_megahit.binning \
    # data/short_read_pooled_megahit_assembly/naughty_sammet_0.binning \
#   -l "MetaBAT 2.13-33 (A1),MetaBAT 2.13-33 (A2),MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),MetaBinner 1.0 (B5),MetaBinner 1.0 (B7),MetaBinner 1.0 (B8),MetaBinner 1.0 (B9),Autometa cami2-146383e (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),Vamb fa045c0 (J1)" \
#   -r data/marine_genome_cat.tsv -k "circular element" \
#   -o results/amber_marine_megahit_nocircular

get_cami_classification_benchmarks () {
  # get_cami_classification_benchmarks camiDir resultsDir output_name
  output_name=$3
  docker run --rm \
    -v $1:${MOUNTED_CAMI_DIR}:ro \
    -v $2:${MOUNTED_RESULTS_DIR}:rw \
    --user=$(id -u):$(id -g) \
    cami-challenge/amber \
        -g ${MOUNTED_CAMI_DIR}/data/ground_truth/marine_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/sleepy_ptolemy_10.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/sleepy_ptolemy_11.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/metabat0.25.4-veryspecific_marine_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_4.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_5.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_11.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_6.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_14.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_19.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_10.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/autometa_marine_megahit_l2000.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/clever_bohr_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/stoic_torvalds_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/stoic_torvalds_1.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/maxbin2.2.7_marine_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/maxbin2.0.2_marine_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/concoct1.1.0_marine_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/concoct0.4.1_marine_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/naughty_sammet_0.binning \
        --labels "${camiLabels}" \
        --remove_genomes ${MOUNTED_CAMI_DIR}/data/marine_genome_cat.tsv \
        --keyword "circular element" \
        --output_dir ${MOUNTED_RESULTS_DIR}/amber-output/${output_name}
}

sample="marmgCAMI2_short_read_pooled_megahit_assembly"
dataset="marine"
# assembly="gsa_pooled_mapping_short.binning"
# camiDir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/${dataset}_dataset/"
camiDir="/home/evan/second_challenge_evaluation/binning/genome_binning/${dataset}_dataset/"
camiLabels="MetaBAT 2.13-33 (A1),MetaBAT 2.13-33 (A2),MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),MetaBinner 1.0 (B5),MetaBinner 1.0 (B7),MetaBinner 1.0 (B8),MetaBinner 1.0 (B9),Autometa cami2-146383e (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),Vamb fa045c0 (J1)"

results="/home/evan/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/${sample}/genome_binning"

mkdir -p "${results}/amber-output"

MOUNTED_RESULTS_DIR="/results"
MOUNTED_CAMI_DIR="/cami"

if [ ! -d ${results}/amber_results_cami ];then
  echo "computing cami submission classification performance metrics"
  get_cami_classification_benchmarks $camiDir $results amber_results_cami &> "${results}/amber-output/amber_results_cami.log"
else
  echo "Skipping cami submissions classification performance metrics computation (already done)"
fi

binnings=()
binningLabels=()
for binning in `find ${results} -name "*.binning"`;do
    binning=$(basename $binning)
    if [[ $binning == *"autometa_ldm_binning"* ]] || [[ $binning == *"autometa_binning_ldm"* ]]
    then
      binningLabel=$(echo $binning | cut -d"." -f3,4,5,6,7,8,9 | sed -e "s,\., ,g" | xargs -I {} echo Autometa 2.1.0 large-data-mode {})
    else
      binningLabel=$(echo $binning | cut -d"." -f3,4,5,6,7 | sed -e "s,\., ,g" | xargs -I {} echo Autometa 2.1.0 {})
    fi
    # e.g. Autometa 2.1.0 hdbscan comp10 pur10 cov10 gc15
    binningLabels+=("${binningLabel}")
    binnings+=("${MOUNTED_RESULTS_DIR}/${binning}")
done

echo "Found ${#binnings[@]} binning results for ${dataset} -> ${sample}"
echo "Created ${#binningLabels[@]} binning labels for ${dataset} -> ${sample}"

# NOW Join labels with published CAMI2 submissions
# See: https://stackoverflow.com/a/17841619

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

sliceLength=100
for startIndex in $(seq 0 $sliceLength ${#binningLabels[@]});do
  sliceBinnings=("${binnings[@]: $startIndex: $sliceLength}")
  sliceLabels=("${binningLabels[@]: $startIndex: $sliceLength}")
  endIndex=$(($startIndex + ${sliceLength} - 1))
  if [ $endIndex -gt ${#binningLabels[@]} ];then
    endIndex=${#binningLabels[@]}
  fi
  outname="amber_results_${startIndex}_to_${endIndex}"
  echo "computing AMBER classification metrics for ${#sliceBinnings[@]} binning results (${#sliceLabels[@]} labels) --> ${outname}"
  joinedLabels=$(join_by ',' "${sliceLabels[@]}")

  nl_binnings=$(join_by '\n' "${sliceBinnings[@]}")
  nl_labels=$(join_by '\n' "${sliceLabels[@]}")
  echo -e ${nl_binnings} > ${results}/amber-output/${outname}_binnings.txt
  echo -e ${nl_labels} > ${results}/amber-output/${outname}_labels.txt

  export OUTNAME=${outname}
  export OUTDIR=${results}
  python -c """
import os
outname = os.environ.get('OUTNAME')
outdir = os.environ.get('OUTDIR')
amber_outdir = os.path.join(outdir, 'amber-output')

binnings_fp = os.path.join(amber_outdir, f'{outname}_binnings.txt')
labels_fp = os.path.join(amber_outdir, f'{outname}_labels.txt')
labels = []
binnings = []
with open(labels_fp) as fh:
  for line in fh:
    labels.append(line.strip())
with open(binnings_fp) as fh:
  for line in fh:
    binnings.append(line.strip())
outlines = 'binning\tlabel\n'
for binning,label in zip(binnings, labels):
  outlines += '\t'.join([binning,label]) + '\n'

with open(os.path.join(amber_outdir, f'{outname}_parameters.tsv'), 'w') as outfh:
    outfh.write(outlines)
  """
  echo "Wrote ${results}/amber-output/${outname}_parameters.tsv"
  rm ${results}/amber-output/${outname}_labels.txt ${results}/amber-output/${outname}_binnings.txt

  # RUN AMBER
  docker run --rm \
    -v $camiDir:${MOUNTED_CAMI_DIR}:ro \
    -v $results:${MOUNTED_RESULTS_DIR}:rw \
    --user=$(id -u):$(id -g) \
    cami-challenge/amber \
        -g ${MOUNTED_CAMI_DIR}/data/ground_truth/marine_megahit.binning \
        ${sliceBinnings[@]} \
        --labels "${joinedLabels}" \
        --remove_genomes ${MOUNTED_CAMI_DIR}/data/marine_genome_cat.tsv \
        --keyword "circular element" \
        --output_dir "${MOUNTED_RESULTS_DIR}/amber-output/${outname}" &> "${results}/amber-output/${outname}.log"
done


export OUTDIR=${results}
python -c """
import os
import glob
import pandas as pd

outdir = os.environ.get('OUTDIR')
amber_dir = os.path.join(outdir, 'amber-output')
results_fpaths = glob.glob(os.path.join(amber_dir, '**', 'results.tsv'), recursive=True)
df = pd.concat([pd.read_table(fp) for fp in results_fpaths])
# Remove duplicates of 'Gold Standard'
df = df.drop_duplicates()
outfpath = os.path.join(amber_dir, 'AMBER_results.tsv.gz')
print(f'Recovered AMBER results for {df.shape[0]-1:,} samples (w/o Gold Standard)')
df.to_csv(outfpath, sep='\t', index=False, header=True)
"""

echo "Wrote ${results}/amber-output/AMBER_results.tsv.gz"