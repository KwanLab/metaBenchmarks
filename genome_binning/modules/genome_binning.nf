#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process METABAT2 {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: params.publish_dir_mode
    disk '100 GB'
    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }
    errorStrategy = 'ignore'
    // errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly), path(depth)

    output:
        tuple val(meta), path("${meta.id}.metabat2.binning.tsv")
    
    script:
        template 'metabat2.sh'
}

process VAMB {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: params.publish_dir_mode
    disk '100 GB'
    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }
    errorStrategy 'ignore'

    input:
        tuple val(meta), path(assembly), path(depth)

    output:
        tuple val(meta), path("${meta.id}.vamb.binning.tsv")
    
    script:
        template 'vamb.sh'
}

process MYCC {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: params.publish_dir_mode
    container "990210oliver/mycc.docker:v1"
    disk '100 GB'
    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }
    errorStrategy = 'ignore'
    // errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }


    input:
        tuple val(meta), path(assembly), path(coverage)

    output:
        tuple val(meta), path("${meta.id}.mycc.binning.tsv"), emit: binning
        tuple val(meta), path("*/Cluster.*.fasta"), emit: clusters
    
    script:
        template 'mycc.sh'
}

process MAXBIN2 {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: params.publish_dir_mode
    disk '100 GB'
    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }
    errorStrategy = 'ignore'
    // errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly), path(coverage)

    output:
        tuple val(meta), path("${meta.id}.maxbin2.binning.tsv")
    
    script:
        template 'maxbin2.sh'
}