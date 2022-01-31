process VAMB {
    // https://github.com/RasmussenLab/vamb
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::vamb" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/vamb:3.0.2--py36hc5360cc_1"
    } else {
        container "quay.io/biocontainers/vamb:3.0.2--py37h73a75cf_1"
    }

    input:
    tuple val(meta), path(assembly), path(bam)

    output:
    tuple val(meta), path("*"), emit: binning

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    vamb \\
        --outdir . \\
        --fasta ${assembly} \\
        --bamfiles ${bam} \\
        $args \\
        $args2 \\
        $args3
    """
}
