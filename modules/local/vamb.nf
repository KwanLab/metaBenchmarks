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
    tuple val(meta), path(fasta), path(bam)

    output:
    tuple val(meta), path("*"), emit: bam

    script:
    def args = task.ext.args ?: ''
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    vamb \\
        --outdir . \\
        --fasta ${fasta} \\
        --bamfiles ${bam} \\
        -o C \\
        --minfasta 200000

    """
}
