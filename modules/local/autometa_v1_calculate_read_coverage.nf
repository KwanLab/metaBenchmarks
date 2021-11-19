// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

// To build docker image locally:
// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:1.0.3

process AUTOMETA_V1_CALCULATE_READ_COVERAGE {

    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    container "jasonkwan/autometa:1.0.3"

    input:
    tuple val(meta), path(contigs), path(forward_reads), path(reverse_reads)

    output:
    tuple val(meta), path("coverage.tab"), emit: coverage

    """
    calculate_read_coverage.py \\
        --assembly ${contigs} \\
        --processors ${task.cpus} \\
        --forward_reads ${forward_reads} \\
        --reverse_reads ${reverse_reads} \\
        ${options.args}

    """
}
