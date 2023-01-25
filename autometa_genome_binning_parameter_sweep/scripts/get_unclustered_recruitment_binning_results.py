#!/usr/bin/env python

import argparse
import os
import re
import glob
import subprocess
import shutil

def check_err_log(err):
    clf_p = re.compile(r'root: classifier=(\w+), seed=\d+, n.estimators=\d+, confidence=\w*')
    p = re.compile(r'root: unclustered\s\d+\s->\s\d+\s\(recruited\s(\d+)\scontigs\)\sin\s\d+\sruns')
    classifier = ""
    n_contigs = 0
    recruitments = {}
    with open(err) as fh:
        for line in fh:
            recruited_match = p.search(line)
            clf_match = clf_p.search(line)
            if clf_match:
                classifier = clf_match.group(1)
            if recruited_match:
                n_contigs = int(recruited_match.group(1))
                recruitments[classifier] = n_contigs
                if n_contigs:
                    print(f"{n_contigs:,} recruited in {os.path.basename(err)}")
    return recruitments

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help='Path to directory containing *param_configurations/**/logs/*.err', required=True)
    args = parser.parse_args()
    # *param_configurations/**/logs/*.err
    glob_search = os.path.join(args.input, "*param_configurations", "**", "logs", "*.err")
    logs = glob.glob(glob_search, recursive=True)
    sample_recruitments = []
    for log in logs:
        sample_id = os.path.basename(log).split('.')[0]
        logs_dirpath = os.path.abspath(os.path.dirname(log))
        best_worst_dirpath = os.path.dirname(logs_dirpath)
        recruited_dirpath = os.path.join(best_worst_dirpath, "recruited")
        recruitments = check_err_log(log)
        for classifier, n_contigs in recruitments.items():
            if not n_contigs:
                continue
            # marmgCAMI2_short_read_pooled_megahit_assembly.autometa_v2.hdbscan.comp90.pur80.cov2.gc2.decision_tree.binning.tsv
            # marmgCAMI2_short_read_pooled_megahit_assembly.autometa_v2.hdbscan.comp90.pur80.cov2.gc2.27773.err
            binning_fname = ".".join([os.path.basename(log).rsplit('.', 2)[0], classifier, "binning.tsv"])
            binning_dirpath = os.path.join(best_worst_dirpath, "binning")
            binning_fpath = os.path.join(binning_dirpath, binning_fname)
            cami_dirpath = os.path.join(best_worst_dirpath, "cami")
            if not os.path.exists(cami_dirpath):
                os.makedirs(cami_dirpath)
            cami_fname = binning_fname.replace(".tsv", "")
            cami_fpath = os.path.join(cami_dirpath, cami_fname)
            if os.path.exists(binning_fpath):
                # format binning for AMBER
                if not os.path.exists(recruited_dirpath):
                    os.makedirs(recruited_dirpath)
                recruitment_fp = os.path.join(recruited_dirpath, binning_fname)
                shutil.copy(binning_fpath, recruitment_fp)
                subprocess.call(["autometa-cami-format", "--sample-predictions", binning_fpath, "--results-type", "genome_binning", "--sample-id", sample_id, "--output", cami_fpath])



if __name__ == '__main__':
    main()

