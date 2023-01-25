#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { AUTOMETA_V1; AUTOMETA_V2; MMSEQS2; DIAMOND_BLASTX; KRAKEN2 } from './modules/taxon-profiling.nf'
include { BENCHMARK_CLASSIFICATION as BENCHMARK } from './modules/benchmark.nf'

workflow {

    // Assemblies must follow directory structure:
    // data/assemblies/simulated/<reference_name>/metagenome.filtered.fna
    Channel
        .fromPath(params.assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.id = assembly.getParent().getName()
                return [ meta, assembly ]
        }
        .set{assemblies_ch}
    
    // References must follow directory structure:
    // data/assemblies/simulated/<reference_name>/reference_assignments.tsv.gz
    Channel
        .fromPath(params.references)
        .map {
            reference ->
                def meta = [:]
                meta.id = reference.getParent().getName()
                return [ meta, reference ]
        }
        .set{references_ch}

    Channel
        .value(params.autometa_db)
        .set{autometa_db}

    Channel
        .value(params.mmseqs2_db)
        .set{mmseqs2_db}

    Channel
        .value(params.diamond_db)
        .set{diamond_db}
    
    Channel
        .value(params.kraken2_db)
        .set{kraken2_db}

    AUTOMETA_V1(
        assemblies_ch,
        autometa_db,
    )
    
    AUTOMETA_V2(
        assemblies_ch,
        autometa_db,
    )

    MMSEQS2(
        assemblies_ch,
        mmseqs2_db,
    )
    
    DIAMOND_BLASTX(
        assemblies_ch,
        diamond_db,
    )
    
    KRAKEN2(
        assemblies_ch,
        kraken2_db,
    )

    // Collect predictions then group with respective reference assignments
    AUTOMETA_V1.out
        .mix(AUTOMETA_V2.out)
        .mix(MMSEQS2.out)
        .mix(DIAMOND_BLASTX.out)
        .mix(KRAKEN2.out)
        .groupTuple() // Group by meta.id (See above mapping from assemblies_ch)
        .join(references_ch)
        .set{predictions_ch}
    // predictions channel should be formatted as
    // [ meta, predictions, reference ]

    BENCHMARK(
        predictions_ch,
        autometa_db,
    )

}