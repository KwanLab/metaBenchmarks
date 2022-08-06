#!/usr/bin/env bash

ncbiDir="${HOME}/metaBenchmarks/data/cami/databases"
camiRepo="${HOME}/second_challenge_evaluation"


for sample in marmgCAMI2_short_read_pooled_gold_standard_assembly marmgCAMI2_short_read_pooled_megahit_assembly strmgCAMI2_short_read_pooled_gold_standard_assembly strmgCAMI2_short_read_pooled_megahit_assembly;do
    if [[ $sample == *"strmg"* ]]; then
        dataset="strain_madness"
        if [[ $sample != *"gold_standard"* ]]; then
            echo "Skipping ${sample}"
            continue
        else
            assembly="gsa_pooled_mapping.binning"
            # amber.py -g ../../genome_binning/strain_madness_dataset/data/ground_truth/gsa_pooled_mapping.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/hopeful_kirch_3.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/ppsp1.4_strain_madness.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/kraken2.0.8beta_strain_madness.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/diamond0.9.28_strain_madness.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/megan6.15.2_strain_madness.binning \
            #     --ncbi_dir ../ \
            #     -l "LSHVec cami2,PhyloPythiaS+ 1.4,Kraken 2.0.8-beta,DIAMOND 0.9.28,MEGAN" \
            #     -o data/results/amber_strain_madness_contigs --filter 1
            submissionsDir="${camiRepo}/binning/taxonomic_binning/strain_madness_dataset/data/submissions"
            # NOTE: The following '/submissions/' directory is the mounted submissions directory in the docker container
            submissions=(/submissions/short_read_pooled_gold_standard_assembly/hopeful_kirch_3.binning \
                /submissions/short_read_pooled_gold_standard_assembly/ppsp1.4_strain_madness.binning \
                /submissions/short_read_pooled_gold_standard_assembly/kraken2.0.8beta_strain_madness.binning \
                /submissions/short_read_pooled_gold_standard_assembly/diamond0.9.28_strain_madness.binning \
                /submissions/short_read_pooled_gold_standard_assembly/megan6.15.2_strain_madness.binning)
            labels="LSHVec cami2,PhyloPythiaS+ 1.4,Kraken 2.0.8-beta,DIAMOND 0.9.28,MEGAN, Autometa 2.1.0"
        fi
    else
        dataset="marine"
        if [[ $sample != *"gold_standard"* ]]; then
            echo "Skipping ${sample}"
            continue
        else
            assembly="gsa_pooled_mapping_short.binning"
            # Yoinked (and adapted) from https://github.com/CAMI-challenge/second_challenge_evaluation/tree/master/binning/taxonomic_binning/marine_dataset#amber-command-for-the-binning-of-the-gold-standard-assembly-of-the-marine-dataset
            # amber.py -g ../../genome_binning/marine_dataset/data/ground_truth/gsa_pooled_mapping_short.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/hopeful_kirch_0.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/naughty_blackwell_0.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/kraken2.0.8beta_marine.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/diamond0.9.28_marine.binning \
            #     data/submissions/short_read_pooled_gold_standard_assembly/megan6.15.2_marine.binning \
            #     --ncbi_dir ../ \
            #     -l "LSHVec cami2,PhyloPythiaS+ 1.4, Kraken 2.0.8-beta, DIAMOND 0.9.28, MEGAN 6.15.2" \
            #     -o data/results/amber_marine_contigs \
            #     --filter 1
            submissionsDir="${camiRepo}/binning/taxonomic_binning/marine_dataset/data/submissions"
            # NOTE: The following '/submissions/' directory is mounted submissions directory in the docker container
            submissions=(/submissions/short_read_pooled_gold_standard_assembly/hopeful_kirch_0.binning /submissions/short_read_pooled_gold_standard_assembly/naughty_blackwell_0.binning /submissions/short_read_pooled_gold_standard_assembly/kraken2.0.8beta_marine.binning /submissions/short_read_pooled_gold_standard_assembly/diamond0.9.28_marine.binning /submissions/short_read_pooled_gold_standard_assembly/megan6.15.2_marine.binning)
            labels="LSHVec cami2, PhyloPythiaS+ 1.4, Kraken 2.0.8-beta, DIAMOND 0.9.28, MEGAN 6.15.2, Autometa 2.1.0"
        fi
    fi
    ground_truths="${HOME}/metaBenchmarks/data/cami/${dataset}/ground_truth"
    results="${HOME}/metaBenchmarks/taxon_binning/nf-taxon-binning-benchmarking-results/${sample}"
    docker run --rm \
        -v $results:/results:rw \
        -v $submissionsDir:/submissions:ro \
        -v $ground_truths:/ground_truths:ro \
        -v $ncbiDir:/ncbi:rw \
        --user=$(id -u):$(id -g) \
        cami-challenge/amber \
            --gold_standard_file ground_truths/$assembly \
            ${submissions[@]} /results/${sample}.autometa_v2.taxonomy.binning \
            --ncbi_dir /ncbi \
            --output_dir /results/amber-output \
            --labels "${labels}" \
            --filter 1

done