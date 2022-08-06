#!/usr/bin/env python

import pandas as pd
import argparse


def get_params_from_dataset(dataset_df: pd.DataFrame) -> pd.DataFrame:
    df = dataset_df.copy()
    df["community"] = df["dataset"].map(lambda x: x.split(".")[0])
    df["cluster_method"] = df["dataset"].map(lambda x: x.split(".")[2])
    df["completeness_cutoff"] = df["dataset"].map(
        lambda x: float(x.split(".")[3].replace("comp", ""))
    )
    df["purity_cutoff"] = df["dataset"].map(
        lambda x: float(x.split(".")[4].replace("pur", ""))
    )
    df["cov_stddev_cutoff"] = df["dataset"].map(
        lambda x: float(x.split(".")[5].replace("cov", ""))
    )
    df["gc_stddev_cutoff"] = df["dataset"].map(
        lambda x: float(x.split(".")[6].replace("gc", ""))
    )
    return df

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        required=True,
        help="input path to output of autometa-benchmark --benchmark binning-classification ...",
    )
    parser.add_argument(
        "--output",
        help="output path to write community benchmarks with dataset expanded to parameter sweep cols",
        default="binning_overview.tsv",
    )
    args = parser.parse_args()
    df = pd.read_table(args.input)
    df = get_params_from_dataset(df)
    df.set_index(["dataset", "reference_genome"], inplace=True)
    df.to_csv(args.output, sep="\t", index=True, header=True)
    print(f"wrote expanded cols to (shape={df.shape}) to {args.output}")


if __name__ == "__main__":
    main()
