process MAXBIN2 {
    tag "$meta.id"
    label 'process_high'

    container "nanozoo/maxbin2:2.2.7--b643a6b"
    
    input:
    tuple val(meta), path(contig), path(fwd_reads), path(rev_reads)

    output:
    tuple val(meta), path("maxbin2_output*"), emit: maxbin2_output
    path "*.version.txt"                    , emit: version

    script:
        def args = task.ext.args ?: ''
        """
        run_MaxBin.pl \\
            -contig ${contig} \\
            -abund ${coverage} \\
            -out maxbin2_output \\
            -thread ${task.cpus} \\
            ${options.args}

        
        run_MaxBin.pl -v | head -n 1 | sed 's/^MaxBin //' > MAXBIN2.version.txt
        """
}

