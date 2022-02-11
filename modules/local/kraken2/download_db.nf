process KRAKEN2_DOWNLOAD_DB {

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
