#!/usr/bin/env bash

run_autometa.py \
    --assembly $assembly \
    --cov_table $coverage \
    --taxonomy_table $taxonomy \
    --processors ${task.cpus} \
    --db_dir $db \
    --output_dir . \
    --length_cutoff 3000 \
    --completeness_cutoff $completeness

mv recursive_dbscan_output.tab ${meta.id}.autometa_v1.comp${completeness}.binning.tsv