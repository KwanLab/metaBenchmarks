process AUTOMETA_BENCHMARK_BINNING {
    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:main"

    input:
        tuple val(meta), path(binning), path(reference)

    output:
        tuple val(meta), path("*.benchmark.tsv"), emit: table

    script:
        def args = task.ext.args ?: ''
        def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        """
        autometa-benchmark \\
            --benchmark binning-classification \\
            --predictions $binning \\
            --reference $reference \\
            --output-wide ${prefix}.binning.benchmark.tsv \\
            ${args}
        """
}