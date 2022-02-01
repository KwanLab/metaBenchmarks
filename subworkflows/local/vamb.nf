
include { VAMB } from '../../modules/local/vamb'
include { MINIMAP2 } from '../../modules/local/minimap2'

workflow VAMB_BENCH {
    take:
        reads
        contigs

    main:
        reads
            .join(
                contigs
            )
            .set{reads_contigs_ch}

        MINIMAP2(reads_contigs_ch)

        // Join the contig and bam files by meta id
        contigs
            .join(
                MINIMAP2.out.bam
            )
            .set{contigs_bam_ch}
        
        VAMB ( contigs_bam_ch )

}
