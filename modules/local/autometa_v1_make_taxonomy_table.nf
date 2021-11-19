// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

// To build docker image locally:
// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:1.0.3

process AUTOMETA_V1_MAKE_TAXONOMY_TABLE {

    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    container "jasonkwan/autometa:1.0.3"


    input:
    tuple val(meta), path(contigs)
    path(db_dir)

    output:
    tuple val(meta), path('Bacteria.fasta')               , emit: bacteria_fasta
    tuple val(meta), path('scaffolds_filtered.fasta')     , emit: scaffolds_filtered_fasta
    tuple val(meta), path('scaffolds_filtered.fasta.tab') , emit: scaffolds_filtered_fasta_tab
    tuple val(meta), path('scaffolds_filtered.orfs.daa')  , emit: scaffolds_filtered_orfs_daa
    tuple val(meta), path('scaffolds_filtered.orfs.faa')  , emit: scaffolds_filtered_orfs_faa
    tuple val(meta), path('scaffolds_filtered.orfs.lca')  , emit: scaffolds_filtered_orfs_lca
    tuple val(meta), path('scaffolds_filtered.orfs.tab')  , emit: scaffolds_filtered_orfs_tab
    tuple val(meta), path('scaffolds_filtered.txt')       , emit: scaffolds_filtered_txt
    tuple val(meta), path('taxonomy.tab')                 , emit: taxonomy_tab
    tuple val(meta), path('unclassified.fasta')           , emit: unclassified_fasta


    """
    make_taxonomy_table.py \
    --assembly ${contigs} \
    --processors ${task.cpus} \\
     --db_dir ${db_dir}\\
    ${options.args} #  e.g. length_cutoff, handled in modules.conf


    """
}
