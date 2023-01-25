#!/usr/bin/env bash

# script:
autometa-markers \
    --orfs $orfs \
    --hmmscan "${kingdom}.hmmscan.tsv" \
    --out "${kingdom}.markers.tsv" \
    --kingdom $kingdom \
    --parallel \
    --cpus ${task.cpus} \
    --seed 42
