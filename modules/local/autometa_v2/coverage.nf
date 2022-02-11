process AUTOMETA_COVERAGE {

    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:main"

    input:
        tuple val(meta), path(assembly), path(bam)

    output:
        tuple val(meta), path("*.coverage.tsv"), emit: table

    script:
        def args = task.ext.args ?: ''
        def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        """
        autometa-coverage \\
            --assembly ${assembly} \\
            --cpus ${task.cpus} \\
            --bam ${bam} \\
            --out ${prefix}.coverage.tsv \\
            ${args}
        """
}