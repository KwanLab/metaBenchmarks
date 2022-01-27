#!/usr/bin/env python

# TODO nf-core: Update the script to check the samplesheet
# This script is based on the example at: https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/samplesheet/samplesheet_test_illumina_amplicon.csv

import os
import sys
import errno
import argparse
from typing import Dict, List


def parse_args(args=None):
    Description = "Reformat nf-core/benchmark samplesheet file and check its contents."
    Epilog = "Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)


def make_dir(path):
    if len(path) > 0:
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise exception


def print_error(error, context="Line", context_str=""):
    error_str = "ERROR: Please check samplesheet -> {}".format(error)
    if context != "" and context_str != "":
        error_str = "ERROR: Please check samplesheet -> {}\n{}: '{}'".format(
            error, context.strip(), context_str.strip()
        )
    print(error_str)
    sys.exit(1)


def write_valid_samplesheet(
    sample_mapping: Dict[str, List[str]], file_out: str
) -> None:
    ## Write validated samplesheet with appropriate columns
    if not sample_mapping:
        print_error("No entries to process!", "Check input samplesheet!")
    out_dir = os.path.dirname(file_out)
    make_dir(out_dir)
    delimiter = "," if file_out.endswith(".csv") else "\t"
    with open(file_out, "w") as fout:
        fout.write(
            delimiter.join(["sample", "single_end", "fastq_1", "fastq_2", "assembly"])
            + "\n"
        )
        for sample in sorted(sample_mapping.keys()):
            ## Check that multiple runs of the same sample are of the same datatype
            if not all(
                entry[0] == sample_mapping[sample][0][0] for entry in sample_mapping[sample]
            ):
                print_error(
                    "Multiple runs of a sample must be of the same datatype!",
                    f"Sample: {sample}",
                )

            for idx, val in enumerate(sample_mapping[sample]):
                fout.write(
                    delimiter.join([f"{sample}_T{idx + 1}"] + val) + "\n"
                )


def check_samplesheet(file_in: str) -> Dict[str, List[str]]:
    """
    This function checks that the samplesheet follows the following structure:

    sample,fastq_1,fastq_2,assembly
    SAMPLE_PE,SAMPLE_PE_RUN1_1.fastq.gz,SAMPLE_PE_RUN1_2.fastq.gz,SAMPLE.fna
    SAMPLE_PE,SAMPLE_PE_RUN2_1.fastq.gz,SAMPLE_PE_RUN2_2.fastq.gz
    SAMPLE_SE,SAMPLE_SE_RUN1_1.fastq.gz,

    For an example see:
    https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/samplesheet/samplesheet_test_illumina_amplicon.csv
    """

    sample_mapping_dict = {}
    with open(file_in, "r") as fin:
        delimiter = "," if file_in.endswith(".csv") else "\t"
        ## Check header
        MIN_COLS = 2
        # TODO nf-core: Update the column names for the input samplesheet
        HEADER = ["sample", "fastq_1", "fastq_2", "assembly"]
        header = [col.strip('"') for col in fin.readline().strip().split(delimiter)]
        if header[: len(HEADER)] != HEADER:
            print(
                "ERROR: Please check samplesheet header -> {} != {}".format(
                    ",".join(header), ",".join(HEADER)
                )
            )
            sys.exit(1)

        ## Check sample entries
        for line in fin:
            sample_entries = [entry.strip().strip('"') for entry in line.strip().split(delimiter)]

            # Check valid number of columns per row
            if len(sample_entries) < len(HEADER):
                print_error(
                    f"Invalid number of columns (minimum = {len(HEADER)})!",
                    "Line",
                    line,
                )
            num_cols = len([entry for entry in sample_entries if entry])
            if num_cols < MIN_COLS:
                print_error(
                    f"Invalid number of populated columns (minimum = {MIN_COLS})!",
                    "Line",
                    line,
                )

            ## Check sample name entries
            sample, fastq_1, fastq_2, assembly = sample_entries[: len(HEADER)]
            sample = sample.replace(" ", "_")
            if not sample:
                print_error("Sample entry has not been specified!", "Line", line)

            ## Check FastQ file extension
            for fastq in [fastq_1, fastq_2]:
                if fastq:
                    if fastq.find(" ") != -1:
                        print_error("FastQ file contains spaces!", "Line", line)
                    if not fastq.endswith(".fastq.gz") and not fastq.endswith(".fq.gz"):
                        print_error(
                            "FastQ file does not have extension '.fastq.gz' or '.fq.gz'!",
                            "Line",
                            line,
                        )

            ## Auto-detect paired-end/single-end
            sample_info = []  ## [single_end, fastq_1, fastq_2, assembly]
            if sample and fastq_1 and fastq_2:  ## Paired-end short reads
                sample_info = ["0", fastq_1, fastq_2, assembly]
            elif sample and fastq_1 and not fastq_2:  ## Single-end short reads
                sample_info = ["1", fastq_1, fastq_2, assembly]
            else:
                print_error("Invalid combination of columns provided!", "Line", line)

            ## Create sample mapping dictionary = { sample: [ single_end, fastq_1, fastq_2, assembly ] }
            if sample not in sample_mapping_dict:
                sample_mapping_dict[sample] = [sample_info]
            else:
                if sample_info in sample_mapping_dict[sample]:
                    print_error("Samplesheet contains duplicate rows!", "Line", line)
                else:
                    sample_mapping_dict[sample].append(sample_info)

    return sample_mapping_dict


def main(args=None):
    args = parse_args(args)
    sample_mapping = check_samplesheet(args.FILE_IN, args.FILE_OUT)
    if not sample_mapping:
        print_error("No entries to process!", f"Samplesheet: {args.FILE_IN}")
    write_valid_samplesheet(sample_mapping, args.FILE_OUT)


if __name__ == "__main__":
    sys.exit(main())
