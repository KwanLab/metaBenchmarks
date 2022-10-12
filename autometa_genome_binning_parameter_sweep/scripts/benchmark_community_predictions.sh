#!/usr/bin/env bash

# communities=(78Mbp 156Mbp 312Mbp 625Mbp 1250Mbp 2500Mbp 5000Mbp 10000Mbp)
# assignmentsRootDir="/media/BRIANDATA4/autometa2_benchmarks/data/assemblies/simulated"
assignmentsRootDir="${HOME}/metaBenchmarks/data/assemblies/simulated"
predictionsRootDir="${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/chtc_data"
communities=("78Mbp" "156Mbp" "312Mbp" "625Mbp" "1250Mbp")
# communities=("78Mbp" "1250Mbp")
benchmarks=()
for community in ${communities[@]};do
	echo "getting benchmarks for $community"
	predictions=(`ls ${predictionsRootDir}/${community}/*.binning.main.tsv`)
	echo "predictions: ${#predictions[@]}"
	reference="${assignmentsRootDir}/${community}/reference_assignments.tsv.gz"
	# benchmark_output="${community}.binning_classification_benchmarks.tsv"
	benchmark_output="${community}.genome_binning_classification_benchmarks.tsv"
	cleaned_output="${community}.genome_binning_classification_benchmarks.munged.tsv"
	if (( ${#predictions[@]}>0 ))
	then
		autometa-benchmark \
			--benchmark binning-classification \
			--predictions ${predictions[@]} \
			--reference $reference \
			--output-wide $benchmark_output
		./convert_dataset_names_to_param_sweep_cols.py \
			--input $benchmark_output \
			--output $cleaned_output
		benchmarks+=($cleaned_output)
	else
		echo "No predictions found for ${community}"
	fi
done

echo "concatenating ${#benchmarks[@]} benchmarks"

python -c """# Concatenate benchmarks
import pandas as pd
import glob
benchmarks = glob.glob('*.genome_binning_classification_benchmarks.munged.tsv')

main_output = 'genome_binning_classification_benchmarks.tsv'

df = pd.concat([pd.read_table(fp) for fp in benchmarks])

df.to_csv(main_output, sep='\t', index=False, header=True)
print(f'Wrote {df.shape} to {main_output}')
"""
