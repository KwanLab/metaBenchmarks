#!/usr/bin/env python

import argparse
import os
import glob


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="Path to MyCC output directory", required=True)
    parser.add_argument("--output", help="Path to output binning.tsv", required=True)

    args = parser.parse_args()

    if not os.path.isdir(args.input):
        raise FileNotFoundError("{} directory not found!".format(args.input))

    outlines = ""
    n_clusters = 0
    for fpath in glob.glob(os.path.join(args.input, "*.fasta")):
        cluster = os.path.basename(fpath).replace(".fasta", "")
        n_clusters += 1
        with open(fpath) as fh:
            for line in fh:
                if line.startswith(">"):
                    contig = line.strip().replace(">", "")
                    outlines += "{}\t{}\n".format(contig, cluster)
    
    header = "contig\tcluster\n"
    with open(args.output, "w") as fh:
        fh.write(header)
        fh.write(outlines)
    
    print("wrote {} MyCC clusters to {}".format(n_clusters, args.output))


if __name__ == '__main__':
    main()
