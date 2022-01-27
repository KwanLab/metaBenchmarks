params.autometa_v1_bin                      = [:]
params.autometa_v1_unclustered_recruitment  = [:]


include{ AUTOMETA_V1_BINNING                     } from "./modules/local/autometa_v1_binning.nf"                    addParams( options: params.autometa_v1_bin                     )
include{ AUTOMETA_V1_CALCULATE_READ_COVERAGE     } from "./modules/local/autometa_v1_calculate_read_coverage.nf"    addParams( options: params.autometa_v1_bin                     )
include{ AUTOMETA_V1_MAKE_TAXONOMY_TABLE         } from "./modules/local/autometa_v1_make_taxonomy_table.nf"        addParams( options: params.autometa_v1_bin                     )
include{ AUTOMETA_V1_UNCLUSTERED_RECRUITMENT     } from "./modules/local/autometa_v1_unclustered_recruitment.nf"    addParams( options: params.autometa_v1_unclustered_recruitment )

workflow AUTOMETA_V1 {
    take:
        contigs // channel: [ val(meta), contigs ]
        contigs_reads // channel: [ val(meta), contigs, forward_reads, reverse_reads ] / read order is important
        taxonomy_table
        db_dir
    main:

        if (params.autometa_v1_calculate_coverage) {    

            AUTOMETA_V1_CALCULATE_READ_COVERAGE(contigs_reads)

        }

        if (params.autometa_v1_make_taxonomy_table) {

            AUTOMETA_V1_MAKE_TAXONOMY_TABLE(contigs)

            AUTOMETA_V1_BINNING(
            AUTOMETA_V1_MAKE_TAXONOMY_TABLE.out.bacteria_fasta,
            AUTOMETA_V1_MAKE_TAXONOMY_TABLE.out.taxonomy_tab,
            db_dir
            )

            AUTOMETA_V1_MAKE_TAXONOMY_TABLE.out.bacteria_fasta
                .join(
                    AUTOMETA_V1_MAKE_TAXONOMY_TABLE.out.taxonomy_tab
                )
                .set { ch_for_binning }

        }
        else { // TODO: Not sure if autometa_v1 
            taxonomy_results = file( "dummy_file.txt", checkIfExists: false )

            contigs
                .combine(taxonomy_results)
                .set { ch_for_binning }

        }

        AUTOMETA_V1_BINNING(
                ch_for_binning
                db_dir

        ) 

        AUTOMETA_V1_BIN.out.recursive_dbscan_output
            .join(
                AUTOMETA_V1_BIN.out.kmer_matrix
            )
            .set { ch_for_unclustered_recruitment}

        AUTOMETA_V1_UNCLUSTERED_RECRUITMENT(
            ch_for_unclustered_recruitment
        )

}
