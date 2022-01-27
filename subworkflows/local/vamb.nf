
include { VAMB } from '../../modules/local/vamb'
include { MINIMAP2_VAMB } from '../../modules/local/minimap2_vamb'

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

        MINIMAP2_VAMB(reads_contigs_ch)

        // Join the contig and bam files by meta id
        contigs
            .join(
                MINIMAP2_VAMB.out.bam
            )
            .set{contigs_bam_ch}
        
        VAMB ( contigs_bam_ch )

}
