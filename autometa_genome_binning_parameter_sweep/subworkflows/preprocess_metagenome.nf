#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


include { KMERS; GC_CONTENT } from '../modules/preprocess.nf'
include { ANNOTATE_MARKERS } from './markers.nf'


workflow PREPROCESS_METAGENOME {
    take:
        assembly
    main:
        GC_CONTENT(
            assembly,
            3000      // length cutoff
        )
        KMERS(
            GC_CONTENT.out.filtered_fasta,
            5,        // kmer_size
            "am_clr", // norm_method
            50,       // pca_dimensions
            "bhsne",  // embed_method
            2,        // embed_dimensions
        )
        ANNOTATE_MARKERS(GC_CONTENT.out.filtered_fasta)
    emit:
        counts = KMERS.out.counts
        kmers = KMERS.out.embedding
        gc_content = GC_CONTENT.out.table
        filtered_fasta = GC_CONTENT.out.filtered_fasta
        orfs = ANNOTATE_MARKERS.out.orfs
        hmmscan = ANNOTATE_MARKERS.out.hmmscan
        markers = ANNOTATE_MARKERS.out.markers
}

workflow {
    // Assemblies must follow directory structure:
    // path/to/assemblies/directory/<sample_name>/metagenome.filtered.fna
    Channel
        .fromPath(params.assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.id = assembly.getParent().getName()
                return [ meta, assembly ]
        }
        .set{assemblies_ch}
    
    // BEGIN AUTOMETA V2 Metagenome Preprocessing

    // Preprocess Metagenome
    PREPROCESS_METAGENOME(assemblies_ch)
    // Assign output channels
    PREPROCESS_METAGENOME.out.gc_content
        .set{gc_content_ch}
    
    PREPROCESS_METAGENOME.out.kmers
        .set{kmers_ch}
    
    PREPROCESS_METAGENOME.out.markers
        .set{markers_ch}

    // Construct channel of Autometa V2 preprocess paths
    kmers_ch
        .join(gc_content_ch)
        .join(markers_ch)
}