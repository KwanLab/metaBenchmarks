#!/usr/bin/env bash

# script:
autometa-length-filter \
    --assembly $assembly \
    --cutoff $length_cutoff \
    --output-fasta "${meta.id}.filtered.fna" \
    --output-gc-content "${meta.id}.gc_content.tsv"
