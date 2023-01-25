#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


process AUTOMETA_V1 {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"

    container "jasonkwan/autometa:1.0.3"
    cpus params.cpus

    input:
        tuple val(meta), path(assembly)
        path db
    
    output:
        tuple val(meta), path("${meta.id}.autometa_v1.taxonomy.tsv")

    script:
        template 'autometa_v1.sh'
}

process AUTOMETA_V2 {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    cpus params.cpus

    input:
        tuple val(meta), path(assembly)
        path db
    
    output:
        tuple val(meta), path("${meta.id}.autometa_v2.taxonomy.tsv")

    script:
        template 'autometa_v2.sh'
}

process MMSEQS2 {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    cpus params.cpus

    input:
        tuple val(meta), path(assembly)
        path db

    output:
        tuple val(meta), path("${meta.id}.mmseqs2.taxonomy.tsv")

    script:
        template 'mmseqs2.sh'
}

process DIAMOND_BLASTX {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    maxForks 1
    cpus params.cpus

    input:
        tuple val(meta), path(assembly)
        path db
    
    output:
        tuple val(meta), path("${meta.id}.diamond_blastx.taxonomy.tsv")

    script:
        template 'diamond_blastx.sh'
}

process KRAKEN2 {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: "${params.publish_dir_mode}"
    cpus params.cpus

    input:
        tuple val(meta), path(assembly)
        path db
    
    output:
        tuple val(meta), path("${meta.id}.kraken2_taxonomy.tsv")

    script:
        template 'kraken2.sh'
}