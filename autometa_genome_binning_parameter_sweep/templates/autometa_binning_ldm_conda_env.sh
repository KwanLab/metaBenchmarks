#!/bin/bash
# Autometa large-data-mode genome-binning template used with conda env

## BEGING SETUP ENV
# From https://chtc.cs.wisc.edu/uw-research-computing/conda-installation.html#3-create-software-package
# replace env-name on the right hand side of this line with the name of your conda environment
ENVNAME=autometa
# if you need the environment directory to be named something other than the environment name, change this line
ENVDIR=$ENVNAME

# these lines handle setting up the environment; you shouldn't have to modify them
export PATH
mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
. $ENVDIR/bin/activate
## END SETUP ENV

set -e

# The enumerated args come from arguments in submit file...
cluster_method=$1
completeness=$2
purity=$3
cov_stddev_limit=$4
gc_stddev_limit=$5
community=$6
# norm_method="am_clr" #am_clr, ilr, clr
norm_method=$7 #am_clr, ilr, clr
embed_method=$8 #bhsne,umap,sksne,trimap,densmap
pca_dims=50
# embed_dims=2
embed_dims=$9
max_partition_size=350000
cpus=4
cache="${community}_autometa_binning_ldm_${cluster_method}_${norm_method}_${embed_method}_${embed_dims}_comp${completeness}_${purity}_${cov_stddev_limit}_${gc_stddev_limit}_cache"
output_binning="${community}.autometa_binning_ldm.${cluster_method}.${norm_method}.${embed_method}_${embed_dims}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.tsv"
output_main="${community}.autometa_binning_ldm.${cluster_method}.${norm_method}.${embed_method}_${embed_dims}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.main.tsv"

python autometa/bin/autometa-binning-ldm \
    --kmers 5mers.tsv.gz \
    --coverages coverage.tsv \
    --gc-content gc_content.tsv \
    --markers bacteria.markers.tsv \
    --taxonomy taxonomy.tsv \
    --clustering-method $cluster_method \
    --completeness $completeness \
    --purity $purity \
    --cov-stddev-limit $cov_stddev_limit \
    --gc-stddev-limit $gc_stddev_limit \
    --norm-method $norm_method \
    --pca-dims $pca_dims \
    --embed-method $embed_method \
    --embed-dims $embed_dims \
    --max-partition-size $max_partition_size \
    --starting-rank superkingdom \
    --rank-filter superkingdom \
    --rank-name-filter bacteria \
    --cpus $cpus \
    --cache $cache \
    --output-binning $output_binning \
    --output-main $output_main

tar -czf ${cache}.tar.gz $cache
# NOTE: 
# To list all files in cache:
# tar -tvf ${cache}.tar.gz


rm -rf $ENVDIR
rm -rf $ENVNAME.tar.gz
