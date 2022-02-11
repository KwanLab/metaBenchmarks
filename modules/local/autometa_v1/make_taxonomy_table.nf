// To build docker image locally:
// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:1.0.3

process AUTOMETA_V1_MAKE_TAXONOMY_TABLE {

    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:1.0.3"

    input:
        tuple val(meta), path(assembly)
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

    script:
        def args = task.ext.args ?: ''
        """
        make_taxonomy_table.py \\
            --assembly ${assembly} \\
            --processors ${task.cpus} \\
            --db_dir ${db_dir}\\
            ${args} #  e.g. length_cutoff, handled in modules.conf
        """
}
