#!/usr/bin/env bash

deepthought="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"

chtc="/home/erees/autometa_runs/binning_param_sweep/data/cami"
# chtc="data/cami/marmgCAMI2_short_read_pooled_megahit_assembly/*{autometa_ldm_binning,autometa_binning_ldm}*"

for sample_dir in `ls -d ${deepthought}/*assembly`;do
	sample=$(basename $sample_dir)
	# Transfer binning results
	rsync -azP chtc:"${chtc}/${sample}/*autometa_{ldm_binning,binning_ldm}*.tsv" "${sample_dir}/autometa_binning_ldm/"
	# Transfer caches
	rsync -azP chtc:"${chtc}/${sample}/*cache.tar.gz" "${sample_dir}/autometa_binning_ldm/"
	# Transfer logs
	rsync -azP chtc:"${chtc}/${sample}/autometa_{binning_ldm,ldm_binning}_logs/" "${sample_dir}/autometa_binning_ldm_logs/"
	rsync -azP chtc:"${chtc}/${sample}/logs/" "${sample_dir}/autometa_binning_logs/"
done
