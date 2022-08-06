#!/usr/bin/env bash


# need to change the contig names in `depth.txt` to match the contig name in the catalogue assembly.
# On running `concatenate.py` vamb prefixed "S1C" to each contig ID in the final catalogue file
# Prepend S1C to each contig except for the first line (ie. the header).
# https://stackoverflow.com/a/2099478/12671809 and https://stackoverflow.com/a/6869486/12671809
# sed -e '2,\$s/^/S1C/' $depth > catalogue_depth.txt

# NOTE: using --keepnames allows us to use the input $depth file

concatenate.py --keepnames catalogue.fna.gz $assembly

# -t : starting batch size
# -o : binsplit separator [None = no split]
# -p : number of subprocesses to spawn [min(8, nbamfiles)]
# --jgi : path to output of jgi_summarize_bam_contig_depths
# --fasta : path to fasta file
# --outdir : output directory to create
vamb \
    -t 8 \
    --outdir out \
    --fasta catalogue.fna.gz \
    --jgi $depth \
    -p ${task.cpus}

# Writes clusters.tsv (no header) to --outdir
echo -e "contig\tcluster" > ${meta.id}.vamb.binning.tsv
cat out/clusters.tsv >> ${meta.id}.vamb.binning.tsv
