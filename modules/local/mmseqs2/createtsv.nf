process MMSEQS2_CREATETSV {
    tag "$meta.id"
    label 'process_medium'
    
    conda (params.enable_conda ? "bioconda::mmseqs2=13.45111" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'soedinglab/mmseqs2' }"

    input:
        tuple val(meta), path(query), path(result)
        path(database)

    output:
        tuple val(meta), path("*.mmseqs2.taxonomy.tsv"), emit: taxonomy
        path "versions.yml",                             emit: versions

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        # usage: mmseqs createtsv <i:queryDB> [<i:targetDB>] <i:resultDB> <o:tsvFile> [options]
        mmseqs createtsv \\
            $query \\
            $database \\
            $result \\
            ${prefix}.mmseqs2.taxonomy.tsv \\
            --threads ${task.cpus} \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mmseqs2: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
