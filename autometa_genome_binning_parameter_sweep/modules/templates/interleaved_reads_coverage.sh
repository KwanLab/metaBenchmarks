#!/usr/bin/env bash

# See:
# https://bitbucket.org/jason_c_kwan/autometa/src/03e0d77a7f6c91df723705414dec587e2a5c72ef/pipeline/calculate_read_coverage.py#lines-59:78
# script:
# Build bowtie2 db using assembly
bowtie2-build $assembly ${meta.id}
# align reads to assembly
bowtie2 -x ${meta.id} \
    --interleaved $reads \
    -q \
    --phred33 \
    --very-sensitive \
    --no-unal \
    -p ${task.cpus} \
    -S alignments.sam

autometa-coverage \
    --cpus ${task.cpus} \
    --assembly $assembly \
    --sam alignments.sam \
    --bam alignments.bam \
    --bed alignments.bed \
    --out ./coverage.tsv

