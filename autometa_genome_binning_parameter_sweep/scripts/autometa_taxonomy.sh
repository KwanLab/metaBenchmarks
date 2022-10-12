#!/bin/bash

set -e

## BEGIN conda env configuration
# replace env-name on the right hand side of this line with the name of your conda environment
# ENVNAME=autometa
# # if you need the environment directory to be named something other than the environment name, change this line
# ENVDIR=$ENVNAME

# # these lines handle setting up the environment; you shouldn't have to modify them
# export PATH
# mkdir $ENVDIR
# cp /staging/groups/kwan_group/autometa-no-dbs.tar.gz .
# tar -xzf autometa-no-dbs.tar.gz -C $ENVDIR
# . $ENVDIR/bin/activate

## END conda env configuration

## BEGIN parameter interpolation from autometa_preprocess_taxonomy.sub arguments
# NCBI database directory containing
# 1. *.dmp from taxdum.tar.gz
# 2. nr.dmnd from diamond makedb --in nr.gz --db nr
# 3. prot.accession2taxid[.FULL].gz
# assembly=$1
# db=$2
# community=$3

## BEGIN setup of ncbi dbdir

dbdir="ncbi"
# ncbi_tarball transferred from /home/erees/autometa_runs/binning_param_sweep/data/databases/ncbi.tar.gz
# NOTE: This generates a directory named 'ncbi' containing the *.dmp files
ncbi_tarball="ncbi.tar.gz"

tar -xzf $ncbi_tarball
cp /staging/groups/kwan_group/nr.dmnd $dbdir
cp /staging/groups/kwan_group/prot.accession2taxid.FULL.gz $dbdir

## END setup of ncbi dbdir

## Configure CPUS to match submit file
CPUS=8

## Begin autometa v2 taxonomy workflow

# 1. Generate ORFs for diamond blastp
prodigal -i metagenome.filtered.fna \
    -f "gbk" \
    -o orfs.gbk \
    -a orfs.faa

# 2. Query nr w/ORFs using diamond blastp
diamond blastp \
    --query orfs.faa \
    --evalue 1e-5 \
    --max-target-seqs 200 \
    --block-size 6 \
    --db ${dbdir}/nr.dmnd \
    --threads $CPUS \
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
    --assembly metagenome.filtered.fna \
    --votes votes.tsv \
    --split-rank-and-write superkingdom \
    --ncbi $dbdir \
    --output .

## BEGIN teardown of ncbi dbdir

rm -rf $dbdir $ncbi_tarball

## END teardown of ncbi dbdir
