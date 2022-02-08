
process CHECK_KRAKEN_DB {

    label 'process_low'
    
    conda (params.enable_conda ? "bioconda::kraken2=2.1.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        // This container was taken from official nf-core module for kraken2
        container "https://depot.galaxyproject.org/singularity/mulled-v2-5799ab18b5fc681e75923b2450abaa969907ec98:941789bd7fe00db16531c26de8bf3c5c985242a5-0"
    } else {
        // This container was taken from official nf-core module for kraken2
        // For information on mulled-v2 see https://github.com/BioContainers/mulled
        container "quay.io/biocontainers/mulled-v2-5799ab18b5fc681e75923b2450abaa969907ec98:941789bd7fe00db16531c26de8bf3c5c985242a5-0"
    }

    script:
        """
        kraken2-inspect -db ${params.kraken2_db}
        echo \$(kraken2 --version 2>&1) | sed 's/^.*Kraken version //; s/ .*\$//' > kraken2.version.txt
        """
}

process DOWNLOAD_KRAKEN {

    label 'process_low'

    conda (params.enable_conda ? "conda-forge::curl=7.81.0" : null)
    container "curlimages/curl:7.81.0"

    output:
        path("**/*")

    script:
        """
        curl -s https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20210517.tar.gz | tar -xz  > k2_standard_8gb_20210517
        """
}
