#!/usr/bin/env nextflow


process BENCHMARK_BINNING_CLASSIFICATION {
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    tag("${meta.id}")

    memory { 8.GB * task.attempt }
    cpus { params.cpus * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

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
