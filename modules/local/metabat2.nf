process METABAT2 {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::metabat2=2.15" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/metabat2:2.15--h986a166_1"
    } else {
        container "quay.io/biocontainers/metabat2:2.15--h986a166_1"
    }

    input:
        tuple val(meta), path(assembly), path(bam)

    output:
        tuple val(meta), path("bins/*.fa"),            emit: bins
        tuple val(meta), path("depth.txt"),            emit: depth
        tuple val(meta), path("metabat2.binning.tsv"), emit: binning

    // See https://seqera.io/training/#_script_parameters
    shell:
        def args = task.ext.args ?: ''
        def software = getSoftwareName(task.process)
        def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
        
        '''
        jgi_summarize_bam_contig_depths \\
            --outputDepth depth.txt \\
            !{bam}
        
        metabat2 \\
            --numThreads !{task.cpus} \\
            --inFile !{assembly} \\
            --abdFile depth.txt  \\
            --outFile bins/!{assembly.baseName} \\
            --unbinned \\
            !{args}
        

        T=$(printf '\t')
        header1="contig"
        header2="cluster"

        echo "$header1$T$header2" > metabat2.binning.tsv

        for bin in $(ls bins/!{assembly.baseName}*{[0-9],unbinned}.fa);do
            cluster=$(basename $bin .fa)
            # See https://unix.stackexchange.com/a/527565/450418 and https://stackoverflow.com/a/18890431/12671809
            echo "$(grep ">" $bin | sed 's/^.//' | sed -r "s|$|\t$cluster|")" >> metabat2.binning.tsv
        done
    '''
}
