process MMSEQS2_CREATEDB {
    tag "$blastdb"
    label 'process_high'
    conda (params.enable_conda ? "bioconda::mmseqs2=13.45111" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'soedinglab/mmseqs2' }"

    input:
        path(blastdb)

    output:
        path("mmseqsDb"),     emit: db
        path("versions.yml"), emit: versions

    // https://github.com/soedinglab/MMseqs2/wiki#create-a-seqtaxdb-from-an-existing-blast-database
    script:
        def args = task.ext.args ?: ''
        """
        TODO: Add mmseqs2 params...
        # To see all args: docker run --rm -it soedinglab/mmseqs2 mmseqs -h
        mmseqs createdb $blastdb mmseqsDb

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            mmseqs2: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
        END_VERSIONS
        """
}
