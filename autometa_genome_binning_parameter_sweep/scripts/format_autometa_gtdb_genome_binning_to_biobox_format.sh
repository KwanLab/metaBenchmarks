#!/usr/bin/env bash

GTDB_BINNING_DATA=(`ls /media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/*/gtdb/genome_binning/*.binning.tsv`)

echo "Found ${#GTDB_BINNING_DATA[@]} autometa (w/gtdb taxonomy) genome binning files"

for f in ${GTDB_BINNING_DATA[@]};do
	sample_id=$(basename $(dirname $(dirname $(dirname $f))));
	autometa-cami-format --sample-predictions $f --sample-id $sample_id --results-type genome_binning --output ${f/.tsv/};
done
