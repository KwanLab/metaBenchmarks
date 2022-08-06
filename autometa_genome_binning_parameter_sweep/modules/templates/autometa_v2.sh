#!/usr/bin/env bash

autometa-binning \
    --kmers $kmers \
    --coverages $coverage \
    --gc-content $gc_content \
    --markers $markers \
    --output-binning "${meta.id}.autometa_v2.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.no_metadata.tsv" \
    --output-main "${meta.id}.autometa_v2.${cluster_method}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.tsv" \
    --clustering-method $cluster_method \
    --completeness $completeness \
    --purity $purity \
    --cov-stddev-limit $cov_stddev_limit \
    --gc-stddev-limit $gc_stddev_limit \
    --taxonomy $taxonomy \
    --starting-rank superkingdom \
    --rank-filter superkingdom \
    --rank-name-filter bacteria \
    --cpus ${task.cpus}
