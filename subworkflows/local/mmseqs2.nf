#!/usr/bin/env nextflow

nextflow.enable.dsl=2


include { MMSEQS2_DATABASES as DATABASES } from '../../modules/local/mmseqs2/databases' addParams( options: [:] )
include { MMSEQS2_TAXONOMY as TAXONOMY } from '../../modules/local/mmseqs2/taxonomy' addParams( options: [:] )
include { MMSEQS2_CREATETSV as CREATETSV } from '../../modules/local/mmseqs2/createtsv' addParams( options: [:] )

workflow MMSEQS2 {
    take:
        query_ch
        
    main:
        
        DATABASES()
        mmseqs_nr_db = DATABASES.out.db

        TAXONOMY(query_ch, mmseqs_nr_db)

        query_ch
            .join(TAXONOMY.out.taxaDb)
            .set{createtsv_ch}

        CREATETSV(createtsv_ch, mmseqs_nr_db)
        
    emit:
        taxonomy = CREATETSV.out.taxonomy
        taxaDb = TAXONOMY.out.taxaDb
        db = DATABASES.out.db
}

workflow {
    fasta_input = file("https://raw.githubusercontent.com/RasmussenLab/vamb/master/test/data/fasta.fna.gz")
    def meta = [:]
    meta.id = "mmseqs2_test"

    array = [ meta, fasta_input ]

    Channel
        .of(array)
        .set{query_ch}
    
    MMSEQS2(query_ch)
}