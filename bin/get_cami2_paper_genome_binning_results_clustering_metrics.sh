#!/usr/bin/env bash

# 1. Find *.binning files for each sample
# 2. Translate labels for each sample for each <result_id>.binning
# 3. Convert *.binning to *.binning.tsv for autometa-benchmark
# 4. Run autometa-benchmark --benchmark clustering on meyer et. al. results
# 5. Concat benchmarks with parameter sweep benchmarks
# 6. Re-create clustering metrics figures