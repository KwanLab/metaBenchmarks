#!/usr/bin/env bash

# script:
autometa-kmers \
    --fasta $assembly \
    --kmers "${kmer_size}mers.tsv" \
    --size $kmer_size \
    --norm-output "${kmer_size}mers.${norm_method}.tsv" \
    --norm-method $norm_method \
    --pca-dimensions $pca_dimensions \
    --embedding-output "${kmer_size}mers.${norm_method}.${embed_method}.tsv" \
    --embedding-method $embed_method \
    --embedding-dimensions $embed_dimensions \
    --cpus ${task.cpus} \
    --seed 42
