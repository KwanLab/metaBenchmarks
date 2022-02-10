process SAMPLESHEET_CHECK {

    conda (params.enable_conda ? "conda-forge::python=3.8.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/python:3.8.3"
    } else {
        container "quay.io/biocontainers/python:3.8.3"
    }

    input:
        path samplesheet

    output:
        path '*.csv'

    script: // This script is bundled with the pipeline, in nf-core/benchmark/bin/
        """
        check_samplesheet.py \\
            $samplesheet \\
            samplesheet.valid.csv
        """
}
