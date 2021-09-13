// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process VAMB {
    // https://github.com/RasmussenLab/vamb
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

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
