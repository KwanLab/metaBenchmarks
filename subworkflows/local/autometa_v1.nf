params.autometa_v1_bin                      = [:]
params.autometa_v1_unclustered_recruitment  = [:]


include{ AUTOMETA_V1_BIN                     } from "./modules/local/autometa_v1.nf"                          addParams( options: params.autometa_v1_bin                      )
include{ AUTOMETA_V1_UNCLUSTERED_RECRUITMENT } from "./modules/local/autometa_v1_unclustered_recruitment.nf"  addParams( options: params.autometa_v1_unclustered_recruitment  )

workflow AUTOMETA_V1 {
    take:
        contigs
        taxonomy_table
        db_dir

    AUTOMETA_V1_BIN(
        contigs,
        taxonomy_table,
        db_dir
    )

    AUTOMETA_V1_UNCLUSTERED_RECRUITMENT(
        AUTOMETA_V1_BIN.out.recursive_dbscan_output, 
        AUTOMETA_V1_BIN.out.kmer_matrix    
    )
    
}
