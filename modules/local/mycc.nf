process MYCC {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "YOUR-TOOL-HERE" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        //container "https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE"
    } else {
        container "990210oliver/mycc.docker:v1"
    }

    input:
    tuple val(meta), path(metagenome)
    path(coverages)

    output:
    tuple val(meta), path("*.fasta"), emit: bins
    path "*.tsv"                    , emit: binning
    path "*.version.txt"            , emit: version

    script:
    def args = task.ext.args ?: ''
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
        # Check coverages table for header and reformat if necessary
        if grep -q 'contig'$'\t''coverage' $coverages
        then 
        echo "Found header, removing...";
        sed -i 1d $coverages
        else
        echo "No header found";
        fi

        # NOTE: MyCC can NOT handle gzipped assemblies
        # Perform MyCC binning
        MyCC.py \\
            $metagenome \\
            -a $coverages \\
            $args


        # Writes out in format: YYYYMMDD_HHMM_mer_lt
        # lt default is 0.7 -> 0.7
        # kmer default is 4 -> 4mer
        # coverage table provided -> _cov
        # Output directory final format: YYYYMMDD_HHMM_4mer_0.7_cov
        # The following 
        # 1. retrieves all output directories with the format as listed above
        # 2. sort dirs by YYYYMMDD_HHMM
        # 3. reverse the order so the latest generated outdir is the 0th element
        # 4. retrieve this 0th element
        outdir=\$(ls -1d *_cov | sort -nr | head -n1)

        # Create contig, cluster column tab-delimited table using latest binning outdir
        format_mycc_output.py --input \$outdir --output mycc.binning.tsv

        # MyCC does not have a version so this will be manually created here
        echo "1.0.0" > ${software}.version.txt
    """
}
