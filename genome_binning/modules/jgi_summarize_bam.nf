#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process JGI_SUMMARIZE_BAM {
    tag "${meta.id}"
    publishDir "${params.outdir}/${meta.id}", mode: params.publish_dir_mode
    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }

    input:
        tuple val(meta), path(bam)

    output:
        tuple val(meta), path("${meta.id}.coverage.depth.tsv")

    script:
        template 'jgi_summarize_bam_contig_depths.sh'
}
