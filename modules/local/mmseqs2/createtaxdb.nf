process MMSEQS2_CREATETAXDB {
    tag '$db'
    label 'process_high'

    conda (params.enable_conda ? "bioconda::mmseqs2=13.45111" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'soedinglab/mmseqs2' }"

    input:
        path db

    output:
        path "*.taxdb", emit: taxdb
        path "versions.yml"           , emit: versions

    script:
        def args = task.ext.args ?: ''
        """
        TODO: Add mmseqs2 params...
        # To see all args: docker run --rm -it soedinglab/mmseqs2 mmseqs -h
        mmseqs createtaxdb -h

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mmseqs2: \$(echo \$(mmseqs --version 2>&1) | sed 's/^.*MMseqs2 Version: //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
