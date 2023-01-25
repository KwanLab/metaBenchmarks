#!/usr/bin/env nextflow
nextflow.enable.dsl = 2


include { AUTOMETA_V1; AUTOMETA_V2; } from './modules/genome_binning.nf'
include { KMERS; GC_CONTENT } from './modules/preprocess.nf'
include { ANNOTATE_MARKERS } from './subworkflows/markers.nf'
include { BENCHMARK_BINNING_CLASSIFICATION as BENCHMARK } from './modules/benchmark.nf'

workflow {

    // Assemblies must follow directory structure:
    // data/assemblies/simulated/<reference_name>/metagenome.filtered.fna
    Channel
        .fromPath(params.assemblies)
        .map {
            assembly ->
                def meta = [:]
                meta.id = assembly.getParent().getName()
                return [ meta, assembly ]
        }
        .set{assemblies_ch}
    
    // References must follow directory structure:
    // data/assemblies/simulated/<reference_name>/reference_assignments.tsv.gz
    Channel
        .fromPath(params.references)
        .map {
            reference ->
                def meta = [:]
                meta.id = reference.getParent().getName()
                return [ meta, reference ]
        }
        .set{references_ch}
    
    // Taxonomy tables must follow directory structure:
    // data/assemblies/simulated/<reference_name>/autometa_v1_taxonomy.tsv
    Channel
        .fromPath(params.v1_taxonomy)
        .map {
            taxonomy ->
                def meta = [:]
                meta.id = taxonomy.getParent().getName()
                return [ meta, taxonomy ]
        }
        .set{v1_taxonomy_ch}

    // Taxonomy tables must follow directory structure:
    // data/assemblies/simulated/<reference_name>/taxonomy.tsv
    Channel
        .fromPath(params.v2_taxonomy)
        .map {
            taxonomy ->
                def meta = [:]
                meta.id = taxonomy.getParent().getName()
                return [ meta, taxonomy ]
        }
        .set{v2_taxonomy_ch}
    
    // Coverage tables must follow directory structure:
    // data/assemblies/simulated/<reference_name>/coverage.tsv
    Channel
        .fromPath(params.v2_coverage)
        .map {
            coverage ->
                def meta = [:]
                meta.id = coverage.getParent().getName()
                return [ meta, coverage ]
        }
        .set{v2_coverage_ch}
    
    // autometa v1 coverage tables must follow directory structure:
    // data/assemblies/simulated/<reference_name>/autometa_v1_coverage.tsv
    Channel
        .fromPath(params.v1_coverage)
        .map {
            coverage ->
                def meta = [:]
                meta.id = coverage.getParent().getName()
                return [ meta, coverage ]
        }
        .set{v1_coverage_ch}

    // BEGIN AUTOMETA V2

    // Preprocess:
    GC_CONTENT(
        assemblies_ch,
        3000, // length_cutoff
    )
    GC_CONTENT.out
        .set{gc_content_ch}

    // Preprocess:
    KMERS(
        assemblies_ch,
        5, // kmer_size
        "am_clr", // norm_method
        50, // pca_dimensions
        "bhsne", // embed_method
        2, // embed_dimensions
    )

    KMERS.out
        .set{kmers_ch}

    // Preprocess:
    ANNOTATE_MARKERS(
        assemblies_ch
    )
    ANNOTATE_MARKERS.out
        .set{markers_ch}

    // Construct channel of Autometa V2 paths
    kmers_ch
        .join(v2_coverage_ch)
        .join(gc_content_ch)
        .join(markers_ch)
        .join(v2_taxonomy_ch)
        .set{autometa_v2_path_ch}

    // Construct channel of Autometa V2 parameters
    Channel.fromList(params.cluster_method)
        .set{cluster_methods_ch}
    Channel.fromList(params.completeness)
        .set{completenesss_ch}
    Channel.fromList(params.purity)
        .set{purity_ch}
    Channel.fromList(params.cov_stddev_limit)
        .set{cov_stddev_limits_ch}
    Channel.fromList(params.gc_stddev_limit)
        .set{gc_stddev_limits_ch}

    cluster_methods_ch
        .combine(completenesss_ch)
        .combine(purity_ch)
        .combine(cov_stddev_limits_ch)
        .combine(gc_stddev_limits_ch)
        .set{autometa_param_sweep_ch}

    // Construct Autometa V2 input channel of paths and params
    autometa_v2_path_ch
        .combine(autometa_param_sweep_ch)
        .set{autometa_v2_input_ch}

    AUTOMETA_V2(
        autometa_v2_input_ch
    )

    // END OF AUTOMETA V2

    // BEGIN AUTOMETA V1
    // Construct channels for Autometa v1
    Channel
        .value(params.autometa_db)
        .set{autometa_db}

    // Retrieve Autometa v1 filepaths
    assemblies_ch
        .join(v1_coverage_ch)
        .join(v1_taxonomy_ch)
        .set{autometa_v1_path_ch}

    // Conduct parameter sweep over completeness cutoff
    autometa_v1_path_ch
        .combine(completenesss_ch)
        .set{autometa_v1_input_ch}

    AUTOMETA_V1(
        autometa_v1_input_ch,
        autometa_db
    )

    // END OF AUTOMETA V1

    // Collect predictions then group with respective reference assignments
    AUTOMETA_V2.out
        .mix(AUTOMETA_V1.out)
        .groupTuple() // Group by meta.id (See above mapping from assemblies_ch)
        .join(references_ch)
        .set{predictions_ch}
    // predictions channel should be formatted as
    // [ meta, predictions, reference ]

    BENCHMARK(
        predictions_ch,
    )
}