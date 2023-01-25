#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process GC_CONTENT {
    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"
    tag "${meta.id}"

    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly)
        val(length_cutoff)
    
    output:
        tuple val(meta), path("gc_content.tsv"),          emit: table
        tuple val(meta), path("${meta.id}.filtered.fna"), emit: filtered_fasta

    script:
        template 'autometa_gc_content.sh'
}

process KMERS {
    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"
    tag "${meta.id}"
    
    memory { 16.GB * task.attempt }
    cpus { params.cpus * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly)
        val(kmer_size)
        val(norm_method)
        val(pca_dimensions)
        val(embed_method)
        val(embed_dimensions)
    
    output:
        tuple val(meta), path("${kmer_size}mers.tsv"),                                emit: counts
        tuple val(meta), path("${kmer_size}mers.${norm_method}.tsv"),                 emit: norm_freqs
        tuple val(meta), path("${kmer_size}mers.${norm_method}.${embed_method}.tsv"), emit: embedding

    script:
        template 'autometa_kmers.sh'
}

process TAXONOMY {
    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"
    tag "${meta.id}"
    
    memory { 16.GB * task.attempt }
    cpus { params.cpus * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly)
    
    output:
        tuple val(meta), path("taxonomy.tsv")

    script:
        template 'autometa_taxonomy.sh'
}

process CONCAT_READS {
    tag "${meta.id}"

    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"

    input:
        tuple val(meta), path(reads)
    output:
        tuple val(meta), path("${meta.id}_pooled_short_read_samples.fq.gz")
    script:
        """
        cat $reads > ${meta.id}_pooled_short_read_samples.fq.gz
        """
}

process COVERAGE {
    tag "${meta.dataset}: ${meta.id}"

    container 'jasonkwan/autometa:latest'
    
    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"
    
    memory { 16.GB * task.attempt }
    cpus { params.cpus * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly), path(reads)
    
    output:
        tuple val(meta), path("alignments.sam"), emit: sam
        tuple val(meta), path("alignments.bam"), emit: bam
        tuple val(meta), path("alignments.bed"), emit: bed
        tuple val(meta), path("coverage.tsv"), emit: tsv

    script:
        template 'interleaved_reads_coverage.sh'
}
