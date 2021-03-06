process KRAKEN2 {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::kraken2=2.1.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        // This container was taken from official nf-core module for kraken2
        container "https://depot.galaxyproject.org/singularity/mulled-v2-5799ab18b5fc681e75923b2450abaa969907ec98:941789bd7fe00db16531c26de8bf3c5c985242a5-0"
    } else {
        // This container was taken from official nf-core module for kraken2
        // For information on mulled-v2 see https://github.com/BioContainers/mulled
        container "quay.io/biocontainers/mulled-v2-5799ab18b5fc681e75923b2450abaa969907ec98:941789bd7fe00db16531c26de8bf3c5c985242a5-0"
    }

    input:
    tuple val(meta), path(contigs)
    path  db

    output:
    tuple val(meta), path('*report.txt')   , emit: report
    tuple val(meta), path('*output.txt')   , emit: output
    path "*.version.txt"                   , emit: version

    script:
    def args = task.ext.args ?: ''
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    kraken2 \\
        --db $db \\
        ${args} \\
        --threads $task.cpus \\
        --output ${prefix}.kraken2.output.txt \\
        --report ${prefix}.kraken2.report.txt \\
        $contigs

    echo \$(kraken2 --version 2>&1) | sed 's/^.*Kraken version //; s/ .*\$//' > ${software}.version.txt
    """
}
