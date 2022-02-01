process MMSEQS2 {
    tag "$meta.id"
    label 'process_high'
    
    conda (params.enable_conda ? "bioconda::mmseqs2=13.45111" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/biocontainers/soedinglab/mmseqs2' }"

    input:
        tuple val(meta), path(bam)

    output:
        tuple val(meta), path("*.bam"), emit: bam
        path "versions.yml"           , emit: versions

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        TODO: Add mmseqs2 params...
        mmseqs easy-taxonomy

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mmseqs2: \$(echo \$(mmseqs2 --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
