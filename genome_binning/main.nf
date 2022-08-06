#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { CONTIG_COVERAGE } from './Autometa/subworkflows/local/contig_coverage.nf'
include { METABAT2; MYCC; MAXBIN2; VAMB } from './modules/genome_binning.nf'
include { JGI_SUMMARIZE_BAM } from './modules/jgi_summarize_bam.nf'
include { BENCHMARK_BINNING_CLASSIFICATION as BENCHMARK } from './modules/benchmark.nf'

workflow {

    // Reads must follow directory structure:
    // data/reads/simulated/<reference_name>/forward_reads.fastq.gz
    Channel
        .fromPath(params.fwd_reads)
        .map {
            fwd_reads ->
                def meta = [:]
                meta.id = fwd_reads.getParent().getName()
                meta.cov_from_assembly = '0'
                return [ meta, file(fwd_reads) ]
        }
        .set{fwd_reads_ch}
    
    // Reads must follow directory structure:
    // data/reads/simulated/<reference_name>/reverse_reads.fastq.gz
    Channel
        .fromPath(params.rev_reads)
        .map {
            rev_reads ->
                def meta = [:]
                meta.id = rev_reads.getParent().getName()
                meta.cov_from_assembly = '0'
                return [ meta, file(rev_reads) ]
        }
        .set{rev_reads_ch}
    
    // Assemblies must follow directory structure:
    // data/assemblies/simulated/<reference_name>/metagenome.filtered.fna
    Channel
        .fromPath(params.assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.id = assembly.getParent().getName()
                meta.cov_from_assembly = '0'
                return [ meta, file(assembly) ]
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
                meta.cov_from_assembly = '0'
                return [ meta, reference ]
        }
        .set{references_ch}

    fwd_reads_ch
        .join(rev_reads_ch)
        .groupTuple()
        .set{reads_ch}
    
    assemblies_ch
        .join(reads_ch)
        .set{coverage_input_ch}

    CONTIG_COVERAGE(
        coverage_input_ch
    )
    // emit: sam, bam, bed, coverage
    
    // Prepare coverage for metabat2 input
    // will create depth.txt input channel for metabat2 and vamb
    JGI_SUMMARIZE_BAM(
        CONTIG_COVERAGE.out.bam
    )

    // Format channel inputs for binners using depths table from JGI
    assemblies_ch
        .join(JGI_SUMMARIZE_BAM.out)
        .set{assembly_depth_ch}

    VAMB(
        assembly_depth_ch
    )
    METABAT2(
        assembly_depth_ch
    )

    // Format channel inputs for binners using coverage table
    assemblies_ch
        .join(CONTIG_COVERAGE.out.coverage)
        .set{assembly_coverage_ch}

    // MYCC(
    //     assembly_coverage_ch
    // )
    MAXBIN2(
        assembly_coverage_ch,
    )

    // Collect predictions then group with respective reference assignments
    MAXBIN2.out
        .mix(METABAT2.out)
        // .mix(MYCC.out.binning)
        .mix(VAMB.out)
        .groupTuple() // Group by meta.id (See above mapping from assemblies_ch)
        .join(references_ch)
        .set{predictions_ch}
    // predictions channel should be formatted as
    // [ meta, predictions, reference ]

    BENCHMARK(
        predictions_ch,
    )

}