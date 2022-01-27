#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// example command to run:
// cd into "metabenchmarks" diectory 
// nextflow run modules/local/tests/vamb.nf -profile conda

include{ VAMB } from "../vamb.nf"

workflow {

    bam_input   = file("https://raw.githubusercontent.com/RasmussenLab/vamb/master/test/data/two.bam")
    fasta_input = file("https://raw.githubusercontent.com/RasmussenLab/vamb/master/test/data/fasta.fna.gz")
    def meta = [:]
    meta.id = "test"

    array = [ meta, fasta_input, bam_input]
    println(array)

    VAMB(array)
}
