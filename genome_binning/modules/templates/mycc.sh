#!/usr/bin/env bash

# Check coverages table for header and reformat if necessary
if  grep -q -e 'contig\s' -e 'coverage\$' $coverage
then
    echo "Found header, removing..."
    awk 'BEGIN{OFS="\t"} {print \$1, \$4}' $coverage | tail -n +2 > mycc_coverage.tsv
else
    echo "No header found. continuing with provided coverages table..."
    mv $coverage mycc_coverage.tsv
fi
# NOTE: MyCC can NOT handle gzipped assemblies
# Perform MyCC binning
MyCC.py \\
    $assembly \\
    -meta \\
    -t 3000 \\
    -a mycc_coverage.tsv

# Writes out in format: YYYYMMDD_HHMM_mer_lt
# lt default is 0.7 -> 0.7
# kmer default is 4 -> 4mer
# coverage table provided -> _cov
# Output directory final format: YYYYMMDD_HHMM_4mer_0.7_cov
# The following 
# 1. retrieves all output directories with the format as listed above
# 2. sort dirs by YYYYMMDD_HHMM
# 3. reverse the order so the latest generated outdir is the 0th element
# 4. retrieve this 0th element
outdir=\$(ls -1d *_cov | sort -nr | head -n1)
echo "Found MyCC outdir: \${outdir}"

# Create contig, cluster column tab-delimited table using latest binning outdir
format_mycc_output.py --input \$outdir --output ${meta.id}.mycc.binning.tsv