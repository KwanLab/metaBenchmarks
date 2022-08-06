#!/usr/bin/env nextflow


process BENCHMARK_CLASSIFICATION {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    input:
        tuple val(meta), path(predictions), path(reference)
        path ncbi

    output:
        path "${meta.id}.classification_benchmarks.tsv", emit: benchmarks
        path "${meta.id}_classification_reports", emit: classification_reports

    script:
        """
        autometa-benchmark \\
            --benchmark classification \\
            --predictions $predictions \\
            --reference $reference \\
            --ncbi $ncbi \\
            --output-classification-reports ${meta.id}_classification_reports \\
            --output-wide ${meta.id}.classification_benchmarks.tsv
        """
}
