process MMSEQS2_TAXONOMY {
    tag "$meta.id"
    label 'process_high'
    
    conda (params.enable_conda ? "bioconda::mmseqs2=13.45111" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'soedinglab/mmseqs2' }"

    scratch true

    input:
        tuple val(meta), path(query)
        path(database)

    output:
        tuple val(meta), path("*.taxaDb"), emit: taxaDb
        path "versions.yml"              , emit: versions

    script:
        def args = task.ext.args ?: ''
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        # usage: mmseqs taxonomy <i:queryDB> <i:targetDB> <o:taxaDB> <tmpDir> [options]
        mmseqs taxonomy \\
            $query \\
            $database \\
            ${prefix}.taxaDb \\
            --threads ${task.cpus} \\
            $args
        

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mmseqs2: \$(echo \$(mmseqs --version 2>&1) | sed 's/^.*MMseqs2 Version: //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
