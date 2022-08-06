#!/usr/bin/env bash

# Previous Genome Binning submissions found in:
# https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/genome_binning/strain_madness_dataset/data/short_read_pooled_gold_standard_assembly

# The following was the command used for the CAMI2 paper:
# From -> https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/genome_binning/strain_madness_dataset#amber-command-for-the-binning-of-the-gold-standard-assembly-of-the-strain-madness-dataset

# amber.py -g data/ground_truth/gsa_pooled_mapping.binning \
#   data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_16.binning \
#   data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_17.binning \
#   data/short_read_pooled_gold_standard_assembly/metabat0.25.4-veryspecific_strain_madness.binning \
#   data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_0.binning \
#   data/short_read_pooled_gold_standard_assembly/tender_sammet_0.binning \
#   data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_17.binning \
#   data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_7.binning \
#   data/short_read_pooled_gold_standard_assembly/sad_shockley_0.binning \
#   data/short_read_pooled_gold_standard_assembly/cranky_wright_0.binning \
#   data/short_read_pooled_gold_standard_assembly/furious_pare_1.binning \
#   data/short_read_pooled_gold_standard_assembly/stoic_torvalds_4.binning \
#   data/short_read_pooled_gold_standard_assembly/sleepy_bohr_0.binning \
#   data/short_read_pooled_gold_standard_assembly/sleepy_bohr_1.binning \
#   data/short_read_pooled_gold_standard_assembly/elated_bardeen_1.binning \
#   data/short_read_pooled_gold_standard_assembly/maxbin2.0.2_strain_madness.binning \
#   data/short_read_pooled_gold_standard_assembly/sleepy_mclean_2.binning \
#   data/short_read_pooled_gold_standard_assembly/concoct0.4.1_strain_madness.binning \
#   data/short_read_pooled_gold_standard_assembly/compassionate_brown_0.binning \
#   data/short_read_pooled_gold_standard_assembly/modest_tesla_0.binning \
#   data/short_read_pooled_gold_standard_assembly/elated_bohr_0.binning \
#   data/short_read_pooled_gold_standard_assembly/drunk_wilson_0.binning \
#   data/short_read_pooled_gold_standard_assembly/vamb_fa045c0_strain_madness_l2000.binning \
#   -l "MetaBAT 2.13-33 (A1),MetaBAT 2.13-33 (A2),MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B1),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),Autometa cami2-03e0d77 (C1),Autometa cami2-03e0d77 (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),UltraBinner 1.0 (E3),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),SolidBin 1.3 (H1),SolidBin 1.3 (H2),SolidBin 1.3 (H3),LSHVec cami2 (I1),Vamb fa045c0 (J1)" \
#   -o results/amber_strain_madness

sample="strmgCAMI2_short_read_pooled_gold_standard_assembly"
dataset="strain_madness"
camiDir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/${dataset}_dataset/"
labels="MetaBAT 2.13-33 (A1),MetaBAT 2.13-33 (A2),MetaBAT 0.25.4 (A3),MetaBinner 1.0 (B1),MetaBinner 1.0 (B2),MetaBinner 1.0 (B3),MetaBinner 1.0 (B4),Autometa cami2-03e0d77 (C1),Autometa cami2-03e0d77 (C2),MetaWRAP 1.2.3 (D1),UltraBinner 1.0 (E1),UltraBinner 1.0 (E2),UltraBinner 1.0 (E3),MaxBin 2.2.7 (F1),MaxBin 2.0.2 (F2),CONCOCT 1.1.0 (G1),CONCOCT 0.4.1 (G2),SolidBin 1.3 (H1),SolidBin 1.3 (H2),SolidBin 1.3 (H3),LSHVec cami2 (I1),Vamb fa045c0 (J1)"
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
        -g ${MOUNTED_CAMI_DIR}/data/ground_truth/gsa_pooled_mapping.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_16.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_17.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/metabat0.25.4-veryspecific_strain_madness.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/tender_sammet_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_17.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_7.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sad_shockley_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/cranky_wright_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_pare_1.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/stoic_torvalds_4.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_bohr_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_bohr_1.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/elated_bardeen_1.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/maxbin2.0.2_strain_madness.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_mclean_2.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/concoct0.4.1_strain_madness.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/compassionate_brown_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/modest_tesla_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/elated_bohr_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/drunk_wilson_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/vamb_fa045c0_strain_madness_l2000.binning \
        ${binnings[@]} \
        --labels "${allLabels}" \
        --output_dir ${MOUNTED_RESULTS_DIR}/amber-output &> "amber_autometa_genome_binning_${sample}.log"
