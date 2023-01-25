#!/usr/bin/env bash

# Function to join labels and binning with arg
# Usage: 
# labels=(binning_1 binning_2 binning_3)
# IN: join_by ',' ${array[@]}
# OUT: binning_1,binning_2,binning_3
function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

bash /media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/scripts/format_autometa_gtdb_genome_binning_to_biobox_format.sh

# Specify docker mount volumes
MOUNTED_RESULTS_DIR="/results"
MOUNTED_CAMI_DIR="/cami"

cami_samples=(`ls -d /media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/*_assembly/gtdb`)
for sample_results in ${cami_samples[@]};do
    sample_id=$(basename $(dirname $sample_results))
    # Determine CAMI ground truth file depending on sample_id
    # 1. determine dataset --> strain_madness || marine
    # 2. determine ground truth filename:
    # marine: gsa_pooled_mapping_short.binning || marine_megahit.binning
    # strain: gsa_pooled_mapping.binning || strain_madness_megahit.binning
    case $sample_id in 
        "marmgCAMI2_short_read_pooled_gold_standard_assembly")
            cami_dir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/marine_dataset/data"
            ground_truth="gsa_pooled_mapping_short.binning"
            remove_genomes_opt="-r ${MOUNTED_CAMI_DIR}/marine_genome_cat.tsv"
            keyword_opt="-k \"circular element\""
            cami_opts="${keyword_opt} ${remove_genomes_opt}"
            ;;
        "marmgCAMI2_short_read_pooled_megahit_assembly")
            cami_dir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/marine_dataset/data"
            ground_truth="marine_megahit.binning"
            remove_genomes_opt="-r ${MOUNTED_CAMI_DIR}/marine_genome_cat.tsv"
            keyword_opt="-k \"circular element\""
            cami_opts="${keyword_opt} ${remove_genomes_opt}"
            ;;
        "strmgCAMI2_short_read_pooled_gold_standard_assembly")
            cami_dir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/strain_madness_dataset/data"
            ground_truth="gsa_pooled_mapping.binning"
            cami_opts=""
            ;;
        "strmgCAMI2_short_read_pooled_megahit_assembly")
            cami_dir="/media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/strain_madness_dataset/data"
            ground_truth="strain_madness_megahit.binning"
            cami_opts=""
            ;;
        "*")
            echo "ground truth for ${sample_id} not found"
            exit
            ;;
    esac
    echo "Found ground truth: ${cami_dir}/${ground_truth}"
    binnings=()
    binningLabels=()
    binning_results=(`find ${sample_results}/genome_binning -name "*.binning"`)
    for binning in ${binning_results[@]};do
        # Add binning and binning label for input to AMBER
        # e.g. marmgCAMI2_short_read_pooled_gold_standard_assembly.autometa_v2.hdbscan.comp20.0.pur95.0.cov25.0.gc5.0.binning
        binning=$(basename $binning)
        binningLabel=$(echo $binning | cut -d"." -f3,4,6,8,10 | sed -e "s,\., ,g" | xargs -I {} echo Autometa gtdb genome-binning {})
        binningLabels+=("${binningLabel}")
        binnings+=("${MOUNTED_RESULTS_DIR}/genome_binning/${binning}")
    done
    joinedLabels=$(join_by ',' "${binningLabels[@]}")

    # Setup AMBER outdir (if it does not exist)
    if [ ! -d "${sample_results}/amber-output" ];then
        mkdir -p "${sample_results}/amber-output"
    fi

    # Perform AMBER classification
    if [ -z "${cami_opts}" ];then
        docker run --rm \
            -v $sample_results:${MOUNTED_RESULTS_DIR}:rw \
            -v $cami_dir:${MOUNTED_CAMI_DIR}:ro \
            --user=$(id -u):$(id -g) \
            cami-challenge/amber \
                -g "${MOUNTED_CAMI_DIR}/ground_truth/${ground_truth}" \
                ${binnings[@]} \
                --labels "${joinedLabels}" \
                --output_dir "${MOUNTED_RESULTS_DIR}/amber-output"
    else
        echo "Additional cami options: ${cami_opts}"
        docker run --rm \
            -v $sample_results:${MOUNTED_RESULTS_DIR}:rw \
            -v $cami_dir:${MOUNTED_CAMI_DIR}:ro \
            --user=$(id -u):$(id -g) \
            cami-challenge/amber \
                -g "${MOUNTED_CAMI_DIR}/ground_truth/${ground_truth}" \
                ${binnings[@]} \
                --labels "${joinedLabels}" \
                "${cami_opts}" \
                --output_dir "${MOUNTED_RESULTS_DIR}/amber-output"
    fi
done
