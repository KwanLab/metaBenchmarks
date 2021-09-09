// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process METABAT2 {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }


    conda (params.enable_conda ? "bioconda::metabat2=2.15" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/metabat2:2.15--h986a166_1"
    } else {
        container "quay.io/biocontainers/metabat2:2.15--h986a166_1"
    }

    input:
    tuple val(meta), path (assembly), path(bam)

    output:
    tuple val(meta), path("bins/*.fa"),  emit: bins
    tuple val(meta), path("depth.txt"), emit: depth

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    jgi_summarize_bam_contig_depths \\
        --outputDepth depth.txt \\
        $bam
    
    metabat2 \\
        -t "$task.cpus" \\
        -i "$assembly" \\
        -a depth.txt  \\
        -o "bins/${assembly.baseName}" \\
        -m ${params.length_cutoff} \\
        --unbinned \\
        --seed ${params.seed} \\
        $options.args

    """
}
