#!/usr/bin/env bash

make_taxonomy_table.py \
    --assembly $assembly \
    --processors ${task.cpus} \
    --db_dir $db \
    --length_cutoff 3000 \
    --output_dir .

mv taxonomy.tab ${meta.id}.autometa_v1.taxonomy.tsv