#!/usr/bin/env bash

# https://github.com/DerrickWood/kraken2/wiki/Manual
# WIP: DOES NOT CURRENTLY WORK
kraken2-build \
    --build \
    --protein \
    --db $DBNAME \
    --threads ${task.cpus}