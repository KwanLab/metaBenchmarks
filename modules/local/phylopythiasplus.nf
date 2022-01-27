include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PHYLOPYTHIASPLUS {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    container "cami/ppsp:1.4"

    input:
    tuple val(meta), path(results), path(assembly), path(dbfile), path(refseq), path(s16db), path(mgdb)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*.bam"), emit: bam
    // TODO nf-core: List additional required output channels/values here
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
        ./opt/run_ppsp.py \\
            --pipelineDir ppsp_output \\
            --refSeq $refseq \\
            --mgDatabase $mgdb \\
            --s16Database $s16db \\
            --inputFastaScaffoldsFile $assembly \\
            $options.args \\

        # TODO: write metaBenchmarks/bin/format_ppsp_output.py 
        # to format binning for autometa-benchmark --classification
        # e.g. contig\ttaxid\n
        # format_ppsp_output.py \\
        #     --input ppsp_output \\
        #     --output ppsp.binning.tsv

        echo "1.4" > ${software}.version.txt
    """
}
