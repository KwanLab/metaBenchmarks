
include { JGI_SUMMARIZE_BAM_CONTIG_DEPTHS } from '../modules/local/jgi_summarize_bam_contig_depths' addParams( options: [:] )
include { MINIMAP2 } from '../modules/local/minimap2' addParams( options: [:] )

workflow PREPARE_COVERAGE_INPUT_FORMATS {
    take:
        assembly
        reads

    main:
        
        MINIMAP2(assembly, reads)
        JGI_SUMMARIZE_BAM_CONTIG_DEPTHS(MINIMAP2.out.bam)
        AUTOMETA_COVERAGE(MINIMAP2.out.bam)
        
    emit:
        bam = MINIMAP2.out.bam
        depth = JGI_SUMMARIZE_BAM_CONTIG_DEPTHS.out.depth
        tab = AUTOMETA_COVERAGE.out.table
}