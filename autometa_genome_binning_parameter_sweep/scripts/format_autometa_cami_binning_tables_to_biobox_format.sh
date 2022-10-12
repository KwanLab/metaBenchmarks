#!/usr/bin/env bash

# DATA="${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"
DATA="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"

sample_dirs=($(ls -d ${DATA}/{mar,str}mgCAMI2_short_read_pooled_{gold_standard,megahit}_assembly))
echo "Found ${#sample_dirs[@]} sample dirs"
for sample_dir in ${sample_dirs[@]};do
	sample=$(basename $sample_dir)
	results=(`find $sample_dir -name "*.binning.tsv"`)
	# results=(`ls ${sample_dir}{autometa_binning,autometa_ldm_binning,.}/*.binning.tsv`)
	echo "${sample}: ${#results[@]} binning results"
	formatted=0
	for result in ${results[@]};do
		# Case where .binning.tsv is in root of sample dir
		output="${sample_dir}/genome_binning/$(basename ${result/.tsv/})"
		if [ ! -f $output ];
		then
			autometa-cami-format \
				--sample-predictions $result \
				--sample-id $sample \
				--results-type genome_binning \
				--output $output 2>> "${sample}_biobox_formatting.log"
			((formatted+=1))
		fi
	done
	echo "formatted ${formatted} results of ${#results[@]}"
done
