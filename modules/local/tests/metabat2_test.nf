#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {METABAT2} from '../metabat2.nf'

// example command to run:
// cd into "metaBenchmarks" diectory 
// nextflow run modules/local/tests/metabat2_test.nf -profile <conda/docker>
// Change the bath to aligned and sorted bam file as well as the assembly file

workflow  {
    bam=file("/media/bigdrive1/sidd/nextflow_trial/autometa_runs/78mbp_manual/interim/cov-alignmentsieg74wbx/alignment.bam")
    assembly=file("/media/bigdrive1/sidd/nextflow_trial/test_data/78/78mbp_metagenome.fna")
    //bam=file("<path/to/alignment.bam>")
    //assembly=file("<path/to/assembly.fasta")
    Channel
        .fromPath(assembly)
            .map { name ->
                    def meta = [:]
                    meta.id = name.simpleName
                    return [meta, name, bam]
            }
        .set {ch_assembly}
    METABAT2(ch_assembly)
}

