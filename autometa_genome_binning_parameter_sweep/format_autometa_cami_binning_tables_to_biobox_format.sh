#!/usr/bin/env bash

cd ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami

for f in `ls {mar,str}mgCAMI2_short_read_pooled_{gold_standard,megahit}_assembly/*.binning.tsv`;do
	sample=$(basename $(dirname $f))
	output="${sample}/genome_binning/$(basename ${f/.tsv/})"
	if [ ! -f $output ];
	then
		autometa-cami-format --sample-predictions $f --sample-id $sample --results-type genome_binning --output $output
	fi
done
