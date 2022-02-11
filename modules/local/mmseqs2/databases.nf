process MMSEQS2_DATABASES {
    tag 'formatting nr for mmseqs2'
    label 'process_long'
    
    conda (params.enable_conda ? "bioconda::mmseqs2=13.45111" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'soedinglab/mmseqs2' }"

    scratch true
    storeDir 'db/mmseqs2/NR'

    output:
        path "nrDb",        emit: db
        path "versions.yml", emit: versions

    script:
        def args = task.ext.args ?: ''
        """
        mmseqs databases \\
            NR \\
            nrDb \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mmseqs2: \$(echo \$(mmseqs --version 2>&1) | sed 's/^.*MMseqs2 Version: //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
