#!/usr/bin/env python

from typing import Iterable
import pandas as pd
import os
import glob
from tqdm import tqdm
from autometa.validation.benchmark import get_categorical_labels

def read_das_tool_bin_table(fpath):
    df = pd.read_csv(fpath, sep='\t', header=None, names=["contig", "cluster"], index_col='contig')
    df['length'] = df.index.map(lambda desc: int(desc.split("len=")[-1]))
    df.index = df.index.map(lambda ctg: ctg.split(" ")[0])
    df.cluster = df.cluster.astype("category")
    return df.reset_index()

def get_bin_matrix(fpath):
    df = read_das_tool_bin_table(fpath)
    mat_df = df.pivot(index='contig', columns='cluster', values='length').fillna(0).convert_dtypes()
    return mat_df


def get_binned_one_hot_encoding(fpaths:Iterable)->pd.DataFrame:
    # Square matrix of 1s for binned and 0 for unbinned...
    fpath = fpaths.pop()
    main_df = pd.read_table(fpath, index_col='contig', usecols=['contig','cluster'])
    # main_df.cluster = main_df.cluster.astype("category")
    dataset = os.path.basename(fpath)
    print(f"initial predictions shape: {main_df.shape}")
    main_df = main_df.rename(columns={"cluster":dataset})
    for fpath in tqdm(fpaths, total=len(fpaths), desc='parsing predictions'):
        df = pd.read_table(fpath, index_col='contig', usecols=['contig','cluster'])
        dataset = os.path.basename(fpath)
        # Set to one for presence...
        # df.cluster = df.cluster.astype("category")
        df = df.rename(columns={"cluster":dataset})
        main_df = main_df.join(df, how='outer')
    
    # Convert to categoricals
    for col in main_df.columns:
        main_df[col] = main_df[col].astype("category")
    
    # mat_df = main_df.pivot(index='contig', columns='cluster', values='length')
    # mat_df = main_df.pivot(index='contig', columns='cluster', values='length').fillna(0).convert_dtypes()
    return main_df

##### 
# ref_df.reference_genome = ref_df.reference_genome
# # Assign "unclustered" to NA and convert 'cluster' column to categorical type
# unclustered_idx = pred_df[pred_df.cluster == "unclustered"].index
# pred_df.loc[unclustered_idx, "cluster"] = pd.NA
# pred_df.cluster = pred_df.cluster.astype("category")
# # Merge reference_assignments and predictions
# main_df = pd.merge(pred_df, ref_df, how="left", left_index=True, right_index=True)
# if main_df.empty:
#     raise ValueError(
#         "The provided reference community and predictions do not match!"
#     )
# # Retrieve categorical values for each set of labels (truth and predicted)
# labels_true = main_df.reference_genome.cat.codes.values
# labels_pred = main_df.cluster.cat.codes.values
#####

# def main():
CAMI2_RESULTS_REPO="/media/BRIANDATA4/second_challenge_evaluation"
# Strain Madness GSA
reference_binning = "/media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/data/cami2_genome_binning_clustering_metrics/gsa_pooled_mapping.binning.tsv"
cami2_binning_results=os.path.join(CAMI2_RESULTS_REPO, "/binning/genome_binning/strain_madness_dataset/data/short_read_pooled_gold_standard_assembly")
autometa_binning_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/strmgCAMI2_short_read_pooled_gold_standard_assembly/autometa_binning"
autometa_binning_ldm_results="/media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/strmgCAMI2_short_read_pooled_gold_standard_assembly/autometa_binning_ldm"

## Collect all predictions
predictions = []
for dirpath in [cami2_binning_results, autometa_binning_results,autometa_binning_ldm_results]:
    fpaths = glob.glob(os.path.join(dirpath, '*.binning.tsv'))
    predictions += fpaths

# for prediction in predictions:
#     labels = get_categorical_labels(prediction, reference=reference_binning)
#     break
# print(labels.true)
# print(labels.pred)
df = get_binned_one_hot_encoding(predictions)
# print(df.shape)
# print(df)
# main()s