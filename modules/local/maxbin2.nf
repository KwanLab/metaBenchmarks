// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process MAXBIN2 {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    container "nanozoo/maxbin2:2.2.7--b643a6b"
    
    input:
    tuple val(meta), path(contig), path(fwd_reads), path(rev_reads)

    output:
    tuple val(meta), path("maxbin2_output*"), emit: maxbin2_output
    path "*.version.txt"                    , emit: version

    script:
    """
      
    run_MaxBin.pl \\
        -contig ${contig} \\
        -reads ${fwd_reads} \\
        -reads2 ${rev_reads} \\
        -out maxbin2_output \\
        -thread ${task.cpus} \\
        ${options.args}

    
    run_MaxBin.pl -v | head -n 1 | sed 's/^MaxBin //' > MAXBIN2.version.txt

    """
}

