#!/usr/bin/env bash

# 1. Generate ORFs for diamond blastp
prodigal -i $assembly \
    -f "gbk" \
    -o orfs.gbk \
    -a orfs.faa

# 2. Query nr w/ORFs using diamond blastp
diamond blastp \
    --query orfs.faa \
    --evalue 1e-5 \
    --max-target-seqs 200 \
    --block-size 6 \
    --db ${db}/nr.dmnd \
    --threads ${task.cpus} \
    --out blastp.tsv


# 3. Determine ORFs LCAs from blastp hits
autometa-taxonomy-lca \
    --blast blastp.tsv \
    --dbdir $db \
    --lca-output lca.tsv \
    --sseqid2taxid-output lca.sseqid2taxid.tsv \
    --lca-error-taxids lca.errorTaxids.tsv

# 4. Assign contig taxonomies using ORF LCAs
autometa-taxonomy-majority-vote \
    --lca lca.tsv \
    --output votes.tsv \
    --dbdir $db

# 5. Create taxonomy table w/NCBI lineages
autometa-taxonomy \
    --assembly $assembly \
    --votes votes.tsv \
    --split-rank-and-write superkingdom \
    --ncbi $db \
    --output .

mv taxonomy.tsv ${meta.id}.autometa_v2.taxonomy.tsv

