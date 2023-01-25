#!/usr/bin/env python

import pandas as pd
import os, glob
from tqdm import tqdm

from convert_dataset_names_to_param_sweep_cols import get_params_from_dataset

user = os.path.expanduser("~")
fps = glob.glob(
    f"{user}/metaBenchmarks/autometa_genome_binning_parameter_sweep/chtc_data/*/*.binning.main.tsv"
)

binning_data = []
for fp in tqdm(fps, total=len(fps), desc="Parsing binning tables"):
    df = pd.read_table(fp).dropna(subset=["cluster"])
    n_clusters = df.cluster.nunique()
    medians = df[["completeness", "purity"]].median()
    binning_data.append(
        {
            "dataset": os.path.basename(fp),
            "mag_count": n_clusters,
            "median_purity": medians.purity,
            "median_completeness": medians.completeness,
        }
    )

main_df = pd.DataFrame(binning_data)
main_df = get_params_from_dataset(main_df)
main_df.to_csv("mag_overview.tsv", sep='\t', index=False, header=True)