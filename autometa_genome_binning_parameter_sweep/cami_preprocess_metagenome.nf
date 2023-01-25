#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


include { PREPROCESS_METAGENOME } from './subworkflows/preprocess_metagenome.nf'
include { TAXON_ASSIGNMENT as TAXONOMY } from './Autometa/subworkflows/local/taxon_assignment.nf'

workflow {

    // Outputs will be named by each input assembly's simple name
    Channel
        .fromPath(params.filtered_assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.id = assembly.getSimpleName()
                return [ meta, assembly ]
        }
        .set{assemblies_ch}
    
    PREPROCESS_METAGENOME(assemblies_ch)

    TAXONOMY(assemblies_ch)
}
