#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process AUTOMETA_V1 {
    publishDir "${params.outdir}/${meta.id}/autometa_v1", mode: "${params.publish_dir_mode}"
    tag "${meta.id} completeness=${completeness}"

    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }

    container "jasonkwan/autometa:1.0.3"

    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(assembly), path(coverage), path(taxonomy), val(completeness)
        path db
    
    output:
        tuple val(meta), path("${meta.id}.autometa_v1.comp${completeness}.binning.tsv")

    script:
        template 'autometa_v1.sh'
}

process AUTOMETA_V2 {
    publishDir "${params.outdir}/${meta.id}/autometa_v2", mode: "${params.publish_dir_mode}"
    tag "${meta.id} ${cluster_method} comp:${completeness} pur:${purity} cov:${cov_stddev_limit} gc:${gc_stddev_limit}"

    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }

    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(kmers), path(coverage), path(gc_content), path(markers), path(taxonomy), val(cluster_method), val(completeness), val(purity), val(cov_stddev_limit), val(gc_stddev_limit)
    
    output:
        tuple val(meta), path("${meta.id}.autometa_v2.${cluster_method}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.tsv")

    script:
        template 'autometa_v2.sh'
}
