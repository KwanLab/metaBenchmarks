// To build docker image locally:
// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:1.0.3

process AUTOMETA_V1_CALCULATE_READ_COVERAGE {

    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:1.0.3"

    input:
        tuple val(meta), path(contigs), path(forward_reads), path(reverse_reads)

    output:
        tuple val(meta), path("coverage.tab"), emit: coverage

    script:
        def args = task.ext.args ?: ''
        """
        calculate_read_coverage.py \\
            --assembly ${contigs} \\
            --processors ${task.cpus} \\
            --forward_reads ${forward_reads} \\
            --reverse_reads ${reverse_reads} \\
            ${args}
        """
}
