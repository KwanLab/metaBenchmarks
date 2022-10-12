#!/usr/bin/env python

import argparse
import glob
import re
import os
import pandas as pd
from datetime import datetime,timedelta
from tqdm import tqdm
from typing import Dict, List, Union

def file_path_to_params(log) -> Dict[str, str]:
    filename = os.path.basename(log)
    # marmgCAMI2_short_read_pooled_gold_standard_assembly_autometa_binning_hdbscan_comp30_pur90_cov5_gc5_15941305_1717.log
    dataset, params = filename.split("_autometa_binning_")
    cluster_method, completeness_cutoff, purity_cutoff, coverage_cutoff, gc_cutoff, cluster_id, job_id  = params.replace(".log", "").split("_")
    return {
        "log_filename":filename,
        "dataset":dataset,
        "cluster_method":cluster_method,
        "completeness_cutoff":completeness_cutoff,
        "purity_cutoff":purity_cutoff,
        "coverage_cutoff":coverage_cutoff,
        "gc_cutoff":gc_cutoff,
        "cluster_id":cluster_id,
        "job_id":job_id
    }

def get_runtime_info(log) -> Dict[str,Union[str,int,timedelta]]:
    retcode = pd.NA
    memory = pd.NA
    disk = pd.NA
    dt = pd.NA
    # Example start time string
    # 001 (15941305.1717.000) 2022-06-18 05:23:22 Job executing on host
    start_time_p = re.compile(r".*(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d) Job executing on host.*")
    # Example end time string
    # 005 (15941305.1717.000) 2022-06-18 12:04:44 Job terminated.
    end_time_p = re.compile(r".*(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d) Job terminated.")
    # Example termination string
    # '\t(1) Normal termination (return value 0)\n'
    retcode_p = re.compile(r".*\(return value (\d?)\)")
    # disk usage regex
    disk_p = re.compile(r"\s*Disk\s\(KB\)\s+:\s+(\d+).*")
    # Example memory string
    #    Memory (MB)          :   786       16384     16384 
    mem_p = re.compile(r"\s*Memory\s\(MB\)\s+:\s+(\d+).*")
    with open(log) as fh:
        for line in fh:
            start_time_match = start_time_p.match(line)
            if start_time_match:
                start = start_time_match.group(1)
                start_ts = datetime.strptime(start, "%Y-%m-%d %H:%M:%S")
            end_time_match = end_time_p.match(line)
            if end_time_match:
                end = end_time_match.group(1)
                end_ts = datetime.strptime(end, "%Y-%m-%d %H:%M:%S")
                dt = end_ts - start_ts
            retcode_match = retcode_p.match(line)
            if retcode_match:
                retcode = retcode_match.group(1)
            mem_match = mem_p.match(line)
            if mem_match:
                # NOTE: memory is in in MB
                memory = int(mem_match.group(1))
            disk_match = disk_p.match(line)
            if disk_match:
                # NOTE: disk is in in KB
                disk = int(disk_match.group(1))
                
    return {"disk (KB)":disk, "memory (MB)":memory, "retcode":retcode, "timedelta":dt}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="Path to directory containing logs sub-directories")
    parser.add_argument("--output", help="Path to write out runtime information table")

    args = parser.parse_args()

    log_filepaths = glob.glob(os.path.join(args.input, "*assembly", "logs", "*.log"))

    print(f"Found {len(log_filepaths):,} log files")

    logs_runtimes = []
    for log in tqdm(log_filepaths, total=len(log_filepaths), desc='Parsing logs'):
        log_info = {}
        params = file_path_to_params(log)
        log_info.update(params)
        runtime_info = get_runtime_info(log)
        log_info.update(runtime_info)
        logs_runtimes.append(log_info)

    df = pd.DataFrame(logs_runtimes)
    df.to_csv(args.output, sep='\t', index=False, header=True)

    print(f"Wrote log runtime info to {args.output}")

    max_memory = df['memory (MB)'].max()
    max_disk = df['disk (KB)'].max()
    print(f"Max memory usage: {max_memory:,} (MB)")
    print(f"Max disk usage: {max_disk:,} (KB)")


if __name__ == '__main__':
    main()