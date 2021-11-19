// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

// To build docker image locally:
// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:1.0.3

process AUTOMETA_V1_BINNING {

    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    container "jasonkwan/autometa:1.0.3"


    input:
    tuple val(meta), path(fasta), path(taxonomy_table)
    path(db_dir)

    output:
    tuple val(meta), path("Bacteria_filtered.hmm.tbl"), emit: bacteria_filtered
    tuple val(meta), path("Bacteria_filtered_marker.tab"), emit: bacteria_filtered_marker
    tuple val(meta), path("k-mer_matrix"), emit: kmer_matrix
    tuple val(meta), path("recursive_dbscan_output.tab"), emit: recursive_dbscan_output

    """
    run_autometa.py \
        --assembly Bacteria.fasta \
        --processors ${task.cpus} \
        --taxonomy_table ${taxonomy_table} \
        --db_dir ${db_dir} \
        ${options.args}
    """
}
