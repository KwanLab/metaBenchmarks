#!/usr/bin/env nextflow


process BENCHMARK_BINNING_CLASSIFICATION {
    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }
    publishDir "${params.outdir}/${meta.id}", mode: params.publish_dir_mode
    input:
        tuple val(meta), path(predictions), path(reference)

    output:
        path "${meta.id}.genome_binning_classification_benchmarks.wide.tsv", emit: wide

    script:
        """
        autometa-benchmark \\
            --benchmark binning-classification \\
            --predictions $predictions \\
            --reference $reference \\
            --output-wide ${meta.id}.genome_binning_classification_benchmarks.wide.tsv
        """
}
