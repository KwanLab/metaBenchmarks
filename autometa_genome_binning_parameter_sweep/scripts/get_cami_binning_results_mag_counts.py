#!/usr/bin/env python

import pandas as pd
import os
import glob

bin_metrics_filepaths = glob.glob("benchmarks/genome_binning/cami-genome-binning/**/bin_metrics.tsv*", recursive=True)
print("Locating bin_metrics.tsv files from AMBER")
dfs = []
print(f"Found {len(bin_metrics_filepaths)} bin_metrics.tsv tables")

for fpath in bin_metrics_filepaths:
    df = pd.read_table(fpath)
    mag_counts = df.groupby("Tool")["BINID"].nunique()
    df.groupby("Tool")["BINID"]
    mag_counts.name = "MAG Count"
    mag_df = mag_counts.to_frame()
    dataset = os.path.basename(os.path.dirname(os.path.dirname(fpath)))
    mag_df['dataset'] = dataset
    dfs.append(mag_df)

main_df = pd.concat(dfs)
outfpath = "benchmarks/genome_binning/cami-genome-binning/cami2_genome_binning_results_mag_counts.tsv.gz"
main_df.to_csv(outfpath, sep='\t', header=True, index=True)
print(f"Wrote datasets MAG counts to {outfpath}")
