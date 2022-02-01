#!/usr/bin/env bash

T=$(printf '\t')
header1="contig"
header2="taxid"
echo "$header1$T$header2" > $2

awk 'BEGIN{OFS="\t"} {print $2, $3}' $1 >> $2

#See https://stackoverflow.com/a/1032039/12671809
sed -i 's/\b0\b/1/' $2