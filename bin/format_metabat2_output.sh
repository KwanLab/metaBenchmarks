#!/bin/bash

binningDir=$1
binningFpath=$2

T=$(printf '\t')
header1="contig"
header2="cluster"

echo "$header1$T$header2" > $binningFpath

for bin in $(ls ${binningDir}/*.fa);
do
    cluster=$(basename $bin)
    # Do not report any unclustered contigs.
    if [[ $cluster == *"unbinned"* ]];
    then continue
    fi
    # See https://unix.stackexchange.com/a/527565/450418 and https://stackoverflow.com/a/18890431/12671809
    echo "$(grep ">" $bin | sed 's/^.//' | sed -r "s|$|\t$cluster|")" >> $binningFpath

done
