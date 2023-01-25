#!/usr/bin/env python

import os
import glob
import pandas as pd

user = os.path.expanduser("~")
fps = glob.glob(f"{user}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/*assembly/*.binning.main.tsv")

counts = []
for fp in fps:
    dataset = os.path.basename(fp)
    df = pd.read_table(fp)
    cluster_count = df.cluster.dropna().nunique()
    counts.append({"cluster_count":cluster_count, "dataset":dataset})

mdf = pd.DataFrame(counts)

mdf.to_csv("cluster_counts.tsv", sep='\t', index=False, header=True)

