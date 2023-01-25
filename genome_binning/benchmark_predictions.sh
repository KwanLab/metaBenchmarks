#!/usr/bin/env bash

communities=(78Mbp 156Mbp 312Mbp 625Mbp 1250Mbp 2500Mbp 5000Mbp 10000Mbp)
predictionsDir="/media/bigdrive2/autometa2_benchmarks/binning/nf-binning-benchmarking"
referenceDir="/media/bigdrive2/autometa2_benchmarks/data/assemblies/simulated"
for community in ${communities[@]};do
	predictions=(`ls ${predictionsDir}/${community}/*.binning.tsv`)
	reference="${referenceDir}/${community}/reference_assignments.tsv.gz"
	echo "${#predictions[@]} predictions found for ${community}"
	if [ ! -f $reference ];then
		echo "Could not find reference for community: ${community}"
	fi
	autometa-benchmark \
	    --benchmark binning-classification \
	    --predictions ${predictions[@]} \
	    --reference $reference \
	    --output-wide ${predictionsDir}/${community}.binning_classification_benchmarks.tsv

done
