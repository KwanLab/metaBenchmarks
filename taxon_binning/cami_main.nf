#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { AUTOMETA_V1; AUTOMETA_V2 } from './modules/taxon_binning.nf'
include { CAMI_BENCHMARK } from './modules/cami_benchmark.nf'

workflow {

    // Assemblies meta ids will be named by their simple name for CAMI data:
    // marmgCAMI2_short_read_pooled_megahit_assembly
    // marmgCAMI2_short_read_pooled_gold_standard_assembly
    // strmgCAMI2_short_read_pooled_gold_standard_assembly
    // strmgCAMI2_short_read_pooled_megahit_assembly
    Channel
        .fromPath(params.assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.id = assembly.getSimpleName()
                return [ meta, assembly ]
        }
        .set{assemblies_ch}
    
    // Reference binning files:
    // 1. is marine or strain_madness?
    // 2. is megahit or gold_standard? 
    // marine_megahit.binning
    // gsa_pooled_mapping_short.binning
    // strain_madness_megahit.binning
    // gsa_pooled_mapping.binning
    // 
    // Channel
    //     .fromPath(params.references)
    //     .map {
    //         reference ->
    //             def meta = [:]
    //             // meta.environment = gold_standard ? "gsa_pooled_" : "_megahit"
    //             // is_marine = 'marine' =~ /marine/
    //             meta.environment = reference.getSimpleName().contains("gold_standard") ? "gsa_pooled_" : "_megahit"
    //             // meta.assemblyType = first two chars(ma) ? marine : strain_madness (st)
    //             meta.assemblyType = reference.getSimpleName().subString(2) ? "ma" : "st"
    //             meta.id = reference.getParent().getName()
    //             return [ meta, reference ]
    //     }
    //     .set{references_ch}

    Channel
        .value(params.autometa_db)
        .set{autometa_db}

    // AUTOMETA_V1(
    //     assemblies_ch,
    //    autometa_db,
    // )
    
    AUTOMETA_V2(
        assemblies_ch,
        autometa_db,
    )

    // Collect predictions then group with respective reference assignments
    // AUTOMETA_V1.out
    //     .mix(AUTOMETA_V2.out)
    //     .groupTuple() // Group by meta.id (See above mapping from assemblies_ch)
    //     .join(references_ch)
    //     .set{predictions_ch}
    // predictions channel should be formatted as
    // [ meta, predictions, reference ]

    // CAMI_BENCHMARK(
    //     predictions_ch,
    //     autometa_db,
    // )

}
