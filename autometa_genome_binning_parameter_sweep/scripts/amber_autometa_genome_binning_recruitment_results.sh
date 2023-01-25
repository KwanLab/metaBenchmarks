#!/usr/bin/env bash


camiDir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/${dataset}_dataset/"
results="/media/BRIANDATA4/autometa2_benchmarks/autometa_binning_parameter_sweep/nf-autometa-binning-parameter-sweep-benchmarks/cami/${sample}/genome_binning"
MOUNTED_RESULTS_DIR="/results"
MOUNTED_CAMI_DIR="/cami"


# strmgCAMI2_short_read_pooled_gold_standard_assembly
# marmgCAMI2_short_read_pooled_megahit_assembly


docker run --rm \
    -v $results:${MOUNTED_RESULTS_DIR}:rw \
    -v $camiDir:${MOUNTED_CAMI_DIR}:ro \
    --user=$(id -u):$(id -g) \
    cami-challenge/amber \
        -g ${MOUNTED_CAMI_DIR}/data/ground_truth/gsa_pooled_mapping_short.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_4.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sleepy_ptolemy_4x.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/metabat0.25.4-veryspecific_marine.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_12.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_3.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_ardinghelli_18.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/sharp_bardeen_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/grave_torvalds_1.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/furious_pare_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/pensive_sinoussi_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/elated_bardeen_0.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/maxbin2.0.2_marine.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/concoct1.1.0_marine.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/concoct0.4.1_marine.binning \
        ${MOUNTED_CAMI_DIR}/data/short_read_pooled_gold_standard_assembly/vamb_fa045c0_marine_l2000.binning \
        ${binnings[@]} \
        --labels "${allLabels}" \
        --remove_genomes ${MOUNTED_CAMI_DIR}/data/marine_genome_cat.tsv \
        --keyword "circular element" \
        --output_dir ${MOUNTED_RESULTS_DIR}/amber-output &> amber_autometa_genome_binning_marine_gsa.log