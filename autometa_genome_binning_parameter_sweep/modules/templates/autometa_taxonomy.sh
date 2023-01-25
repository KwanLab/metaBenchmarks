#!/bin/bash

## Begin autometa v2 taxonomy workflow
# 2. Query nr w/ORFs using diamond blastp
diamond blastp \
    --query $orfs \
    --evalue 1e-5 \
    --max-target-seqs 200 \
    --block-size 6 \
    --db ${dbdir}/nr.dmnd \
    --threads ${task.cpus} \
    --out blastp.tsv

# 3. Determine ORFs LCAs from blastp hits
autometa-taxonomy-lca \
    --blast blastp.tsv \
    --dbdir $dbdir \
    --sseqid2taxid-output lca.sseqid2taxid.tsv \
    --lca-error-taxids lca.errorTaxids.tsv \
    --lca-output lca.tsv

# 4. Assign contig taxonomies using ORF LCAs
autometa-taxonomy-majority-vote \
    --lca lca.tsv \
    --output votes.tsv \
    --dbdir $dbdir

# 5. Create taxonomy table w/NCBI lineages
autometa-taxonomy \
    --assembly $assembly \
    --votes votes.tsv \
    --split-rank-and-write superkingdom \
    --ncbi $dbdir \
    --output .