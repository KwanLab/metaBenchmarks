#!/usr/bin/env python

import argparse
import glob
from itertools import product
import os



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        help="Path to data directory for communities"
        "[will glob using string path(args.input/*Mbp)]",
        required=True
    )
    parser.add_argument("--glob", default="*Mbp", help="regex string to use to glob `--input` directory for samples")
    parser.add_argument("--output", help="Path to write parameter sweep combinations", required=True)
    args = parser.parse_args()


    cluster_methods = ['dbscan','hdbscan']
    completeness = list(range(10,100, 10))
    purities = list(range(10,100, 10))
    cov_stddev_limit = [2, 5, 10, 15]
    gc_stddev_limit = [2, 5, 10, 15]

    communities = glob.glob(os.path.join(args.input, args.glob))
    communities = sorted(communities, key=lambda x: int(x.split("/")[-1].replace("Mbp","")) if "Mbp" in x else x)
    print(f"Found {len(communities)} communities")
    
    n_jobs = 0
    outlines = ""
    for community_dir in communities:
        community = os.path.basename(community_dir)
        for combination in product(
            cluster_methods,
            completeness,
            purities,
            cov_stddev_limit,
            gc_stddev_limit,
        ):
            params = ", ".join(map(str,combination)) + "\n"
            outlines += f"{community_dir}, {community}, {params}"
            n_jobs += 1
    with open(args.output, "w") as fh:
        fh.write(outlines)
    print(f"Wrote {n_jobs:,} ({int(n_jobs/len(communities)):,} per community) parameter sweep jobs to {args.output}")

    print("Wrote parameters in the format:")
    print("communityDir, community, cluster_method, completeness, purity, cov_stddev_limit, gc_stddev_limit")

    print("-----"*20)
    print("PLACE the following in your submit file using these parameter combinations:")
    print(f"queue communityDir,community,cluster_method,completeness,purity,cov_stddev_limit,gc_stddev_limit from {args.output}")

if __name__ == "__main__":
    main()