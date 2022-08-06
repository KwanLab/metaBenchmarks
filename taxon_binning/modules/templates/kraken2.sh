#!/usr/bin/env bash

# 1. Perform kraken2 query
kraken2 \
    --db $db \
    --threads ${task.cpus} \
    --output kraken2.output.txt \
    --report kraken2.report.txt \
    $assembly

# Format for autometa-benchmark
## 2. Format diamond blastx taxon-profiling output
echo -e "contig\ttaxid" > ${meta.id}.kraken2_taxonomy.tsv
awk 'BEGIN{OFS="\t"} {print \$2, \$3}' kraken2.output.txt >> ${meta.id}.kraken2_taxonomy.tsv
#See https://stackoverflow.com/a/1032039/12671809
#Kraken2 assigns 0 to the unclassified contigs, but Autometa assigns 1 to them. 
# This command replaces all the single 0s with 1s
# sed -i 's/\b0\b/1/' ${meta.id}.kraken2_taxonomy.tsv