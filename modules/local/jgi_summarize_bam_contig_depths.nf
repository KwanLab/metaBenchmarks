process JGI_SUMMARIZE_BAM_CONTIG_DEPTHS {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::metabat2=2.15" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/metabat2:2.15--h986a166_1"
    } else {
        container "quay.io/biocontainers/metabat2:2.15--h986a166_1"
    }

    input:
        tuple val(meta), path(bam)

    output:
        tuple val(meta), path("depth.txt"), emit: depth
        path("*.version.txt"),              emit: version


    // See https://seqera.io/training/#_script_parameters
    script:
        def args = task.ext.args ?: ''
        def software = getSoftwareName(task.process)
        def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        """
        jgi_summarize_bam_contig_depths \\
            --outputDepth depth.txt \\
            $bam \\
            $args

        echo "2.15" > ${software}.version.txt
        """
}