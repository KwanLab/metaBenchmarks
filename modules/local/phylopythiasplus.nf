process PHYLOPYTHIASPLUS {
    tag "$meta.id"
    label 'process_high'

    container "cami/ppsp:1.4"

    input:
    tuple val(meta), path(results), path(assembly), path(dbfile), path(refseq), path(s16db), path(mgdb)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "*.version.txt"          , emit: version

    script:
    def args = task.ext.args ?: ''
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    samtools \\
        sort \\
        $args \\
        -@ ${task.cpus} \\
        -o ${prefix}.bam \\
        -T ${prefix} \\
        ${bam}

    echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' > ${software}.version.txt
    """
}
