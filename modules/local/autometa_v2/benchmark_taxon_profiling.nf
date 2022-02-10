process AUTOMETA_BENCHMARK_TAXON_PROFILING {

    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:main"

    input:
        tuple val(meta), path(taxonomy), path(reference)
        path(ncbi)

    output:
        tuple val(meta), path("*.benchmark.tsv"),          emit: table
        tuple val(meta), path("*_classification_reports"), emit: classification_reports

    script:
        def args = task.ext.args ?: ''
        def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        """
        autometa-benchmark \\
            --benchmark classification \\
            --predictions $taxonomy \\
            --reference $reference \\
            --output-wide ${prefix}.taxon_profiling.benchmark.tsv \\
            --output-classification-reports ${prefix}_classification_reports
            --ncbi $ncbi \\
            ${args}

        """
}