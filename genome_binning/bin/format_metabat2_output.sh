#!/bin/bash

binningDir="/media/bigdrive2/autometa2_benchmarks/binning/data/metabat2/78Mbp"
cd $binningDir

echo -e "contig\tcluster" > metabat2.binning.tsv

for bin in $(ls ${binningDir}/*.fa);
do
    cluster=$(basename $bin)
    # Do not report any unclustered contigs.
    if [[ $cluster == *"unbinned"* ]];
    then continue
    fi
    # See https://unix.stackexchange.com/a/527565/450418 and https://stackoverflow.com/a/18890431/12671809
    echo "$(grep ">" $bin | sed 's/^.//' | sed -r "s|$|\t$cluster|")" >> metabat2.binning.tsv

done
