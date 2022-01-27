#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {MAXBIN2} from '../maxbin2.nf'

workflow  {
    contig=file("/home/andrew/benchmarking/spades/contigs.fasta")
    read_forward=file("/home/andrew/benchmarking/art/paired_dat_f201.fq")
    read_reverse=file("/home/andrew/benchmarking/art/paired_dat_f202.fq")
    Channel
        .fromPath(contig)
            .map { fasta ->
                    def meta = [:]
                    meta.id = fasta.simpleName
                    return [meta, fasta]
            }
        .set {ch_contig}
    MAXBIN2(ch_contig, read_forward, read_reverse)
}
