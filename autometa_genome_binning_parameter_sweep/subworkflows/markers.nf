#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process ORFS {
    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"
    tag "${meta.id}"
    cpus params.cpus

    memory { 16.GB * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly)
    
    output:
        tuple val(meta), path("orfs.faa")

    script:
        template 'autometa_orfs.sh'
}

process MARKERS {
    publishDir "${params.outdir}/${meta.id}/preprocess", mode: "${params.publish_dir_mode}"
    tag "${meta.id}"
    cpus 4

    memory { 16.GB * task.attempt }
    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }


    input:
        tuple val(meta), path(orfs)
        val(kingdom)
    
    output:
        tuple val(meta), path("${kingdom}.hmmscan.tsv"), emit: hmmscan
        tuple val(meta), path("${kingdom}.markers.tsv"),            emit: markers

    script:
        template 'autometa_markers.sh'
}

workflow ANNOTATE_MARKERS {
  take:
    assembly
  main:
    ORFS(assembly)
    MARKERS(ORFS.out, "bacteria")
  emit:
    orfs = ORFS.out
    hmmscan = MARKERS.out.hmmscan
    markers = MARKERS.out.markers
}
