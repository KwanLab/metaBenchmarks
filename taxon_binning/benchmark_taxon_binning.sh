#!/usr/bin/env bash

dataDir="${HOME}/metaBenchmarks/taxon_binning/data"
referenceDir="${HOME}/metaBenchmarks/data/assemblies/simulated"
ncbi="${HOME}/metaBenchmarks/data/databases/ncbi"
outdir="${HOME}/metaBenchmarks/taxon_binning/data/benchmarks"

# Iterate through simulated communities
for community in 78Mbp 156Mbp 312Mbp 625Mbp 1250Mbp 2500Mbp 5000Mbp 10000Mbp;do
    predictions=(${dataDir}/taxon-profiles/${community}*taxonomy.tsv)
    reference="${referenceDir}/${community}/reference_assignments.tsv.gz"
    classificationReports="${outdir}/${community}_classification_reports"
    benchmarksTable="${outdir}/${community}.classification_benchmarks.tsv"
    benchmarksLog="${outdir}/${community}.classification_benchmarks.log"
    echo "${#predictions[@]} profiles found for ${community}"
    autometa-benchmark \
            --benchmark classification \
            --predictions ${predictions[@]} \
            --reference $reference \
            --ncbi $ncbi \
            --output-classification-reports $classificationReports \
            --output-wide $benchmarksTable &> $benchmarksLog
done