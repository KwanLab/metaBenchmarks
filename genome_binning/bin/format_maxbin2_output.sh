#!/bin/bash

binningDir="/media/bigdrive2/autometa2_benchmarks/binning/maxbin2/78Mbp"
cd $binningDir

echo -e "contig\tcluster" > maxbin2_binning.tsv

for bin in $(ls ${binningDir}/*.fasta);
do
    cluster=$(basename $bin)
    # Do not report any unclustered contigs.
    # See https://unix.stackexchange.com/a/527565/450418 and https://stackoverflow.com/a/18890431/12671809
    echo "$(grep ">" $bin | sed 's/^.//' | sed -r "s|$|\t$cluster|")" >> maxbin2_binning.tsv

done
