#!/usr/bin/env bash

# Perform diamond blastx query
diamond blastx \
    --query $assembly \
    --db $db \
    --threads ${task.cpus} \
    --outfmt 102 \
    --out diamond_blastx.out

## 2. Format diamond blastx taxon-profiling output
echo -e "contig\ttaxid" > ${meta.id}.diamond_blastx.taxonomy.tsv
awk 'BEGIN{OFS="\t"} {print \$1, \$2}' diamond_blastx.out >> ${meta.id}.diamond_blastx.taxonomy.tsv

#Diamond assigns 0 to the unclassified contigs, but autometa assigns 1 to them. 
# This command replaces all the single 0s with 1s
# sed -i 's/\b0\b/1/' ${meta.id}.diamond_blastx.taxonomy.tsv