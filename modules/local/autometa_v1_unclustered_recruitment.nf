// To build docker image locally:
// docker build git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 -t jasonkwan/autometa:1.0.3

process AUTOMETA_V1_UNCLUSTERED_RECRUITMENT {

    tag "$meta.id"
    label 'process_high'

    container "jasonkwan/autometa:1.0.3"

    input:
    tuple val(meta), path(recursive_dbscan_output), path(kmer_marix)

    output:
    tuple val(meta), path("ml_recruitment_output.tab"), emit: ml_recruitment_output

    """
    ML_recruitment.py \
        --contig_tab ${recursive_dbscan_output} \
        --k_mer_matrix ${k-mer_marix} \
        --out_table ml_recruitmtent_output.tab

    """
}
