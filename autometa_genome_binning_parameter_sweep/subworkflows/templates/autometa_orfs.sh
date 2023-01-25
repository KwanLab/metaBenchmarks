#!/usr/bin/env bash

autometa-orfs \
    --assembly $assembly \
    --output-nucls "orfs.fna" \
    --output-prots "orfs.faa" \
    --cpus ${task.cpus}
