process AUTOMETA_BENCHMARK_BINNING {

    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:main"

    input:
    tuple val(meta), path(binning)

    output:
    tuple val(meta), path("*.benchmarks.tsv"), emit: table
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    autometa-benchmark \\
        // TODO: Finish input of args
        ${args}

    """
}