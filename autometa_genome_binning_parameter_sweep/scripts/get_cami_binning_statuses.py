#!/usr/env/bin python

import argparse
from typing import Dict
import pandas as pd
from itertools import product
import glob
import os


def get_current_counts(dirpath) -> pd.DataFrame:
    binning_filepaths = glob.glob(
        os.path.join(dirpath, "*assembly", "*.binning.main.tsv")
    )
    # user = os.path.expanduser("~")
    # binning_filepaths = glob.glob(os.path.join('{user}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-binning-parameter-sweep-benchmarks/cami', "*assembly", "*.binning.main.tsv"))
    datasets = []
    for binning in binning_filepaths:
        dataset = os.path.basename(os.path.dirname(binning))
        binning_basename = os.path.basename(binning)
        datasets.append(
            {
                "dataset": dataset,
                "cluster_method": binning_basename.split(".")[2],
                "comp_cutoff": binning_basename.split(".")[3].replace("comp", ""),
                "pur_cutoff": binning_basename.split(".")[4].replace("pur", ""),
                "cov_cutoff": binning_basename.split(".")[5].replace("cov", ""),
                "gc_cutoff": binning_basename.split(".")[6].replace("gc", ""),
                "finished": True,
            }
        )

    return pd.DataFrame(datasets)

def get_parameter_combinations():
    # From generate_param_sweep_list.py
    cluster_methods = ["dbscan", "hdbscan"]
    completeness = list(range(10, 100, 10))
    purities = list(range(10, 100, 10))
    cov_stddev_limit = [2, 5, 10, 15]
    gc_stddev_limit = [2, 5, 10, 15]
    return list(product(
        cluster_methods,
        completeness,
        purities,
        cov_stddev_limit,
        gc_stddev_limit,
    ))

def get_expected_param_counts() -> pd.Series:
    combinations = get_parameter_combinations()
    combinations_df = pd.DataFrame(
        [
            {
                "cluster_method": cluster_method,
                "comp_cutoff": comp,
                "pur_cutoff": pur,
                "cov_cutoff": cov_std,
                "gc_cutoff": gc_std,
            }
            for cluster_method, comp, pur, cov_std, gc_std in combinations
        ]
    )
    expected_param_counts = {}
    params = [
        "cluster_method",
        "comp_cutoff",
        "pur_cutoff",
        "cov_cutoff",
        "gc_cutoff",
    ]
    for param in params:
        expected_param_count = combinations_df[param].value_counts().iloc[0]
        expected_param_counts.update({param: expected_param_count})
    return pd.Series(expected_param_counts)


def get_progress(current: pd.DataFrame, expected: pd.DataFrame) -> Dict[str, pd.Series]:
    dfs = []
    for param in expected.index.unique().tolist():
        count_df = current[param].value_counts().to_frame().copy()
        expected_count = expected[param]
        count_df = count_df.assign(
            percent_complete=lambda x: round(x[param] / expected_count * 100, 2)
        )
        count_df['progress'] = count_df[param].map(
            lambda x: f'{x}/{expected_count}'
        )
        count_df['is_finished'] = count_df[param].map(
            lambda param_binning_count: expected_count - param_binning_count == 0
        )
        count_df = count_df.reset_index().rename(columns={param:"binning_count", "index":"parameter_value"})
        count_df['parameter'] = param
        dfs.append(count_df)
    return pd.concat(dfs)

def get_progress_df(current: pd.DataFrame, expected: pd.DataFrame) -> pd.DataFrame:
    progress_dfs = []
    for dataset in current.dataset.unique():
        dff = current.loc[current.dataset.eq(dataset)].copy()
        progress_df = get_progress(dff, expected)
        progress_df["dataset"] = dataset
        progress_dfs.append(progress_df)
    return pd.concat(progress_dfs).set_index(["dataset", "parameter", "parameter_value"])

def write_resubmission_parameters():
    params = ", ".join(map(str,combination)) + "\n"
    outlines += f"{community_dir}, {community}, {params}"
    pass

def main():

    user = os.path.expanduser("~")
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        help="Path to directory of cami-sample-results sub-dirs",
        required=False,
        default=f"{user}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami",
    )
    parser.add_argument(
        "--sweep-parameters",
        help="Filepath to write of binning parameter sweep text for .sub file",
        required=True,
    )
    parser.add_argument(
        "--progress",
        help="Filepath to write of datasets binning progress table",
        required=False,
        default="cami_datasets_binning_progress.tsv",
    )
    args = parser.parse_args()

    current_counts = get_current_counts(args.input)
    expected_counts = get_expected_param_counts()
    main_df = get_progress_df(current_counts, expected_counts)
    # print(main_df)

    main_df.to_csv(args.progress, sep='\t', index=True, header=True)
    print(f"Wrote progress table to {args.progress}")

    communities = [os.path.basename(dp) for dp in glob.glob(
        os.path.join(args.input, "*assembly")
    )]
    submission_dir = "data/cami"
    outlines = ""
    counts = {}
    n_params = 0
    n_found = 0
    for community in communities:
        counts[community] = 0
        community_dir = os.path.join(submission_dir, community)
        binning_filepaths = set(glob.glob(
            os.path.join(args.input, community, "*.binning.main.tsv")
        ))
        print(f"found {len(binning_filepaths):,} binning files for {community}")
        combinations = get_parameter_combinations()
        for combination in combinations:
            cluster_method, completeness, purity, coverage, gc = combination
            binning_filename = f"{community}.autometa_v2.{cluster_method}.comp{completeness}.pur{purity}.cov{coverage}.gc{gc}.binning.main.tsv"
            binning_filepath = os.path.join(args.input, community, binning_filename)
            if not os.path.exists(binning_filepath):
                params = ", ".join(map(str,combination))
                param_line = f"{community_dir}, {community}, {params}\n"
                outlines += param_line
                counts[community] += 1
                n_params += 1
            else:
                n_found += 1
    for community,count in counts.items():
        print(f"{community}: {count:,}")

    print(f"Found {n_found:,} binning files")

    with open(args.sweep_parameters, "w") as fh:
        fh.write(outlines)

    print(f"wrote: {n_params:,} params to {args.sweep_parameters}")

    total = n_found + n_params
    print(f"total: {total:,}")
    print(f"resubmissions: {n_params:,} of {total:,} ({round(n_params/total*100, 2)}% remaining)")

if __name__ == "__main__":
    main()
