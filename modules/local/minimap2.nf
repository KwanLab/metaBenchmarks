process MINIMAP2 {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::minimap2=2.12 bioconda::samtools=1.9" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
     //   container "https://depot.galaxyproject.org/singularity/minimap2:2.22--h5bf99c6_0"
    } else {
        container "quay.io/biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:8f2087d838e5270cd83b5a016667234429f16eea-0"
    }

    input:
        tuple val(meta), path(reads), path(assembly)

    output:
        tuple val(meta), path("*.bam"), emit: bam
        path "*.version.txt"          , emit: version

    script:
        def args = task.ext.args ?: ''
        def args2 = task.ext.args2 ?: ''
        def software = getSoftwareName(task.process)
        def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        def input_reads = meta.single_end ? "$reads" : "${reads[0]} ${reads[1]}"
    """
    minimap2 \\
        -t $task.cpus \\
        ${args} \\
        ${args2} \\
        ${assembly} \\
        ${input_reads} | samtools view -F 3584 -b --threads $task.cpus > sample.bam

    echo \$(minimap2 --version 2>&1) > ${software}.version.txt
    samtools --version | head -n1 |  sed -e "s/samtools //g" >> ${software}.version.txt
    """
}
