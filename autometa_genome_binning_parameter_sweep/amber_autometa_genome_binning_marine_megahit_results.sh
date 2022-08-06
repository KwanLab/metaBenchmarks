#!/usr/bin/env bash
#SBATCH --partition=queue
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks
#SBATCH --cpus-per-task=1
#SBATCH --error=%J.amber_marmgCAMI2_megahit.err
#SBATCH --output=%J.amber_marmgCAMI2_megahit.out


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

sample="marmgCAMI2_short_read_pooled_megahit_assembly"
dataset="marine"
# assembly="gsa_pooled_mapping_short.binning"
camiDir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/${dataset}_dataset/"
labels="MetaBAT 2.13-33 (A1),MetaBAT 2.13-33 (A2),MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),MetaBinner 1.0 (B5),MetaBinner 1.0 (B7),MetaBinner 1.0 (B8),MetaBinner 1.0 (B9),Autometa cami2-146383e (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),Vamb fa045c0 (J1)"

results="/media/BRIANDATA4/autometa2_benchmarks/autometa_binning_parameter_sweep/nf-autometa-binning-parameter-sweep-benchmarks/cami/${sample}/genome_binning"

MOUNTED_RESULTS_DIR="/results"
MOUNTED_CAMI_DIR="/cami"

binnings=()
binningLabels=()
for binning in `ls ${results}/*.binning`;do
    binning=$(basename $binning)
    binningLabel=$(echo $binning | cut -f3,4,5,6,7 -d"." | sed -e "s,\., ,g" | xargs -I {} echo Autometa 2.1.0 {})
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

allLabels=$(join_by , "${labels}" "${binningLabels[@]}")

# RUN AMBER
docker run --rm \
    -v $results:${MOUNTED_RESULTS_DIR}:rw \
    -v $camiDir:${MOUNTED_CAMI_DIR}:ro \
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
        ${binnings[@]} \
        --labels "${allLabels}" \
        --remove_genomes ${MOUNTED_CAMI_DIR}/data/marine_genome_cat.tsv \
        --keyword "circular element" \
        --output_dir ${MOUNTED_RESULTS_DIR}/amber-output &> amber_autometa_genome_binning_marine_${sample}.log
