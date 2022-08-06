#!/usr/bin/env bash

# Previous Genome Binning submissions found in:
# https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/genome_binning/strain_madness_dataset/data/short_read_pooled_megahit_assembly

# The following was the command used for the CAMI2 paper:
# From -> https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/genome_binning/strain_madness_dataset#amber-command-for-the-binning-of-the-megahit-assembly

# amber.py -g data/ground_truth/strain_madness_megahit.binning \
#   data/short_read_pooled_megahit_assembly/metabat0.25.4-veryspecific_strain_madness_megahit.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_2.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_8.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_9.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_2x.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_13.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_15.binning \
#   data/short_read_pooled_megahit_assembly/furious_ardinghelli_16.binning \
#   data/short_read_pooled_megahit_assembly/autometa_strain_madness_megahit_l500.binning \
#   data/short_read_pooled_megahit_assembly/clever_bohr_1.binning \
#   data/short_read_pooled_megahit_assembly/stoic_torvalds_2.binning \
#   data/short_read_pooled_megahit_assembly/stoic_torvalds_3.binning \
#   data/short_read_pooled_megahit_assembly/maxbin2.2.7_strain_madness_megahit.binning \
#   data/short_read_pooled_megahit_assembly/maxbin2.0.2_strain_madness_megahit.binning \
#   data/short_read_pooled_megahit_assembly/concoct1.1.0_strain_madness_megahit.binning \
#   data/short_read_pooled_megahit_assembly/concoct0.4.1_strain_madness_megahit.binning \
#   data/short_read_pooled_megahit_assembly/naughty_sammet_1.binning \
#   -l "MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),MetaBinner 1.0 (B5),MetaBinner 1.0 (B6),MetaBinner 1.0 (B7),MetaBinner 1.0 (B8),Autometa cami2-146383e (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),Vamb fa045c0 (J1)" \
#   -o results/amber_strain_madness_megahit

sample="strmgCAMI2_short_read_pooled_megahit_assembly"
dataset="strain_madness"

camiDir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/${dataset}_dataset/"

labels="MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),MetaBinner 1.0 (B5),MetaBinner 1.0 (B6),MetaBinner 1.0 (B7),MetaBinner 1.0 (B8),Autometa cami2-146383e (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),Vamb fa045c0 (J1)"

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
        -g ${MOUNTED_CAMI_DIR}/data/ground_truth/strain_madness_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/metabat0.25.4-veryspecific_strain_madness_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_2.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_8.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_9.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_2x.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_13.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_15.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/furious_ardinghelli_16.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/autometa_strain_madness_megahit_l500.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/clever_bohr_1.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/stoic_torvalds_2.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/stoic_torvalds_3.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/maxbin2.2.7_strain_madness_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/maxbin2.0.2_strain_madness_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/concoct1.1.0_strain_madness_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/concoct0.4.1_strain_madness_megahit.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_megahit_assembly/naughty_sammet_1.binning \
        ${binnings[@]} \
        --labels "${allLabels}" \
        --output_dir ${MOUNTED_RESULTS_DIR}/amber-output &> "amber_autometa_genome_binning_${sample}.log"
