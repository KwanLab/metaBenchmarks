#!/usr/bin/env bash

# 1. Generate queryDB using $assembly
mmseqs createdb $assembly queryDB

# 2. taxon-profile queryDB
# mmseqs taxonomy <i:queryDB> <i:targetDB> <o:taxaDB> <tmpDir> [options]
mmseqs taxonomy \
    queryDB \
    ${db}/mmseqs2_NR \
    mmseqs2.out \
    tmp \
    --tax-lineage 2 \
    --threads ${task.cpus}

# 3. merge chunked output
mmseqs createtsv queryDB mmseqs2.out mmseqs2.out.tsv
# 3. Format for autometa-benchmark
echo -e "contig\ttaxid" > ${meta.id}.mmseqs2.taxonomy.tsv
awk 'BEGIN{OFS="\t"} {print \$1, \$2}' mmseqs2.out.tsv >> ${meta.id}.mmseqs2.taxonomy.tsv
