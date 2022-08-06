#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


include { PREPROCESS_METAGENOME } from './subworkflows/preprocess_metagenome.nf'
include { COVERAGE; CONCAT_READS } from './modules/preprocess.nf'
// include { TAXON_ASSIGNMENT as TAXONOMY } from './Autometa/subworkflows/local/taxon_assignment.nf'


workflow {

    // Outputs will be named by each input assembly's simple name
    Channel
        .fromPath(params.filtered_assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.dataset = assembly.getParent().getParent().getName()
                meta.id = assembly.getSimpleName()
                return [ meta, file(assembly) ]
        }
        .set{assemblies_ch}
    
    // Reads must follow directory structure:
    // data/cami/{dataset}/reads/*short*.fq.gz
    // e.g. data/cami/{marine,strain_madness}/reads/*short*.fq.gz
    Channel
        .fromPath(params.interleaved_reads)
        .map {
            reads ->
                def meta = [:]
                meta.id = reads.getParent().getParent().getName()
                // meta.id = reads.getSimpleName()
                meta.cov_from_assembly = '0'
                return [ meta, file(reads) ]
        }
        .groupTuple()
        .set{reads_ch}

    CONCAT_READS(reads_ch)
    CONCAT_READS.out
        .map{meta, reads -> return tuple(meta.id, file(reads))}
        .set{interleaved_reads_ch}

    // interleaved_reads_ch
    //     .collectFile(name: "pooled_reads_samples.txt", newLine: true)


    // Now group pooled reads to their corresponding assemblies (2 assemblies per sample)
    // strain_madness -> strmgCAMI2_*assembly*filtered.fna
    // marine -> mamgCAMI2_*assembly*filtered.fna
    assemblies_ch
        .map{
            meta, assembly -> 
            return tuple(meta.dataset, meta.id, file(assembly))
        }
        // .groupTuple(by: 0)
        .combine(interleaved_reads_ch, by: 0)
        .map{
            dataset, sample_name, assembly, reads ->
            def meta = [:]
            meta.id = sample_name
            meta.dataset = dataset
            return [ meta, file(assembly), file(reads) ]
        }
        // tuple val(meta), path(assembly), path(reads)
        .set{coverage_input_ch}

    COVERAGE(
        coverage_input_ch
    )

    PREPROCESS_METAGENOME(assemblies_ch)

    // TAXONOMY(assemblies_ch)
}
