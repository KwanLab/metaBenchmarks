#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// requires `nextflow clone kwanlab/Autometa`
include { COUNT_KMERS } from '.Autometa/modules/local/count_kmers.nf'
include { NORMALIZE_KMERS } from '.Autometa/modules/local/normalize_kmers.nf'
include { EMBED_KMERS } from '.Autometa/modules/local/embed_kmers.nf'
include { PREPROCESS_METAGENOME } from './subworkflows/preprocess_metagenome.nf'

workflow {

    // Outputs will be named by each input assembly's simple name
    Channel
        .fromPath(params.assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.dataset = assembly.getParent().getParent().getName()
                meta.id = assembly.getSimpleName()
                return [ meta, file(assembly) ]
        }
        .set{assemblies_ch}
    
    assemblies_ch

    COUNT_KMERS(
        assemblies_ch
    )

    COUNT_KMERS.out.counts
        .set{counts_ch}

    CONTIG_LENGTH_FILTER(
        counts_ch
    )

    CONTIG_LENGTH_FILTER.out
        .set{filtered_counts_ch}

    counts_ch
        .join(filtered_counts_ch)
        .set{all_counts_ch}

    NORMALIZE_KMERS(
        all_counts_chx
    )
    
    NORMALIZE_KMERS.out.normalized
        .set{norm_kmers_ch}

    EMBED_KMERS(
        norm_kmers_ch
    )

    EMBED_KMERS.out.embedded
        .set{embed_kmers_ch}
}