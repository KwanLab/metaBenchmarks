#!/bin/bash

set -e

## BEGIN conda env configuration
# replace env-name on the right hand side of this line with the name of your conda environment
ENVNAME=autometa
# if you need the environment directory to be named something other than the environment name, change this line
ENVDIR=$ENVNAME

# these lines handle setting up the environment; you shouldn't have to modify them
export PATH
mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
. $ENVDIR/bin/activate

## END conda env configuration

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
