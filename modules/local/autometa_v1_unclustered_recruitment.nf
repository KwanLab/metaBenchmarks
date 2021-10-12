// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:metabenchmark-v1

process AUTOMETA_V1_UNCLUSTERED_RECRUITMENT {

    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    container "jasonkwan/autometa:metabenchmark-v1"


    input:
    tuple val(meta), path(recursive_dbscan_output), path(kmer_marix)
    path(taxonomy_table)
    path(db_dir)

    output:
    tuple val(meta), path("ml_recruitment_output.tab"), emit: ml_recruitment_output

    """
    ML_recruitment.py \
        --contig_tab ${recursive_dbscan_output} \
        --k_mer_matrix ${k-mer_marix} \
        --out_table ml_recruitmtent_output.tab

    """
}
