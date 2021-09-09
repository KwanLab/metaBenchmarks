#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {KRAKEN2} from '../kraken2.nf'

// example command to run:
// cd into "metaBenchmarks" diectory 
// nextflow run modules/local/tests/kraken2_test.nf -profile conda
// Change the bath to aligned and sorted bam file as well as the assembly file

workflow  {
    assembly=file("/media/bigdrive1/sidd/nextflow_trial/autometa_runs/78mbp_manual/interim/78mbp_metagenome.filtered.fna")
    db=file("/media/bigdrive1/Databases/kraken2/kraken2_db")
    Channel
        .fromPath(assembly)
            .map { fasta ->
                    def meta = [:]
                    meta.id = fasta.simpleName
                    return [meta, fasta]
            }
        .set {ch_fasta}
    KRAKEN2(ch_fasta, db)
}
