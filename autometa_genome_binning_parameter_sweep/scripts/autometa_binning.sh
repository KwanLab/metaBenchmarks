#!/bin/bash
# NOTE: Required submit file env configuration
# universe = docker
# docker_image = jasonkwan/autometa:2.1.0
# The enumerated args come from arguments in submit file...
cluster_method=$1
completeness=$2
purity=$3
cov_stddev_limit=$4
gc_stddev_limit=$5
community=$6
output_binning="${community}.autometa_v2.${cluster_method}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.tsv"
output_main="${community}.autometa_v2.${cluster_method}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.main.tsv"

autometa-binning \
    --kmers 5mers.am_clr.bhsne.tsv \
    --coverages coverage.tsv \
    --gc-content gc_content.tsv \
    --markers bacteria.markers.tsv \
    --taxonomy taxonomy.tsv \
    --clustering-method $cluster_method \
    --completeness $completeness \
    --purity $purity \
    --cov-stddev-limit $cov_stddev_limit \
    --gc-stddev-limit $gc_stddev_limit \
    --starting-rank superkingdom \
    --rank-filter superkingdom \
    --rank-name-filter bacteria \
    --cpus 4 \
    --output-binning $output_binning \
    --output-main $output_main
