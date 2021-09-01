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
    tuple val(meta), path(bam), path (assembly)

    output:
    tuple val(meta), path("*.fa"),  emit: bins
    tuple val(meta), path("depth.txt"), emit: depth
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/software/homer/annotatepeaks/main.nf

    """
    jgi_summarize_bam_contig_depths \\
        --outputDepth depth.txt \\
        $bam
    
    metabat2 \\
        -t "$task.cpus" \\
        -i "$assembly" \\
        -a depth.txt  \\
        -o "MetaBat2/${assembly.baseName}" \\
        -m ${params.length_cutoff} \\
        --unbinned \\
        --seed ${params.seed} \\
        $options.args

    echo \$(metabat2 --help 2>&1) | sed "s/^.*version 2\\://; s/ (Bioconda.*//" > ${software}.version.txt
    """
}
