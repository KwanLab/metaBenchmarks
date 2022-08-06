#!/usr/bin/env bash

metabat2 \
    --numThreads ${task.cpus} \
    --inFile $assembly \
    --abdFile $depth  \
    --minContig 3000 \
    --saveCls \
    --noBinOut \
    --verbose \
    --outFile metabat2.binning.tsv

echo -e "contig\tcluster" > ${meta.id}.metabat2.binning.tsv
cat metabat2.binning.tsv >> ${meta.id}.metabat2.binning.tsv
