#!/usr/bin/env bash

# Remove header and subset table with only contig\tcoverage information
awk 'BEGIN{OFS="\t"} {print \$1, \$4}' $coverage | tail -n +2 > abund.tsv

run_MaxBin.pl \
    -contig  $assembly \
    -thread ${task.cpus} \
    -out maxbin2_cluster \
    -verbose \
    -abund abund.tsv

echo -e "contig\tcluster" > ${meta.id}.maxbin2.binning.tsv
for cluster in \$(ls maxbin2_cluster.*.fasta);do
    clusterName=\$(basename \$cluster)
    # Do not report any unclustered contigs.
    # See https://unix.stackexchange.com/a/527565/450418 and https://stackoverflow.com/a/18890431/12671809
    echo "\$(grep ">" \$clusterName | sed 's/^.//' | sed -r "s|\$|\t\$clusterName|")" >> ${meta.id}.maxbin2.binning.tsv
done