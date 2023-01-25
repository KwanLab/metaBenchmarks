#!/usr/bin/env nextflow


process CAMI_BENCHMARK {
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    tag "${meta.id}"

    container 'cami-challenge/amber:latest'

    input:
        tuple val(meta), path(predictions), path(reference)
        path ncbi

    output:
        path "${meta.id}_cami_amber_benchmarks", emit: benchmarks

    script:
        // DATASET_TO_TITLE = {'mar': 'Marine', 'sm': 'Strain-madness', 'rhi': 'Plant-associated'}
        // --gold_standard_file ../../genome_binning/marine_dataset/data/ground_truth/gsa_pooled_mapping_short.binning \\
        """
        python AMBER/amber.py \\
            --gold_standard_file $reference \\
            $predictions \\
            --ncbi_dir $ncbi \\
            -o ${meta.id}_cami_amber_benchmarks \\
            --filter 1
        """
}

process AMBER_GSA_SM {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    input:
        tuple val(meta), path(predictions), path(reference)
        path ncbi

    output:
        path "amber_marine_contigs", emit: benchmarks

    script:
        // DATASET_TO_TITLE = {'mar': 'Marine', 'sm': 'Strain-madness', 'rhi': 'Plant-associated'}
        // -g ../../genome_binning/marine_dataset/data/ground_truth/gsa_pooled_mapping_short.binning \\
        """
        amber.py \\
            -g $reference \\
            $predictions \\
            --ncbi_dir $ncbi \\
            -l "LSHVec cami2,PhyloPythiaS+ 1.4, Kraken 2.0.8-beta, DIAMOND 0.9.28, MEGAN 6.15.2" \\
            -o amber_marine_contigs --filter 1
        """
}

process AMBER_GSA_RHI {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    input:
        tuple val(meta), path(predictions), path(reference)
        path ncbi

    output:
        path "rhizosphere_contigs", emit: benchmarks

    script:
        // DATASET_TO_TITLE = {'mar': 'Marine', 'sm': 'Strain-madness', 'rhi': 'Plant-associated'}
        """
        amber.py \\
            -g ../../genome_binning/marine_dataset/data/ground_truth/gsa_pooled_mapping_short.binning \\
            data/submissions/short_read_pooled_gold_standard_assembly/hopeful_kirch_0.binning \\
            data/submissions/short_read_pooled_gold_standard_assembly/naughty_blackwell_0.binning \\
            data/submissions/short_read_pooled_gold_standard_assembly/kraken2.0.8beta_marine.binning \\
            data/submissions/short_read_pooled_gold_standard_assembly/diamond0.9.28_marine.binning \\
            data/submissions/short_read_pooled_gold_standard_assembly/megan6.15.2_marine.binning \\
            --ncbi_dir ../ \\
            -l "LSHVec cami2,PhyloPythiaS+ 1.4, Kraken 2.0.8-beta, DIAMOND 0.9.28, MEGAN 6.15.2" \\
            -o rhizosphere_contigs --filter 1
        """
}
