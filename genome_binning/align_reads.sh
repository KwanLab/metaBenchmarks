#!/bin/bash
#SBATCH --partition=queue
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks
#SBATCH --cpus-per-task=20
#SBATCH --error=align_reads.%J.err
#SBATCH --output=align_reads.%J.out

assembly_dir="/media/bigdrive2/autometa2_benchmarks/data/assemblies/78Mbp"
read_dir="/media/bigdrive2/autometa2_benchmarks/data/reads/78Mbp"
cpus=20
out_dir="/media/bigdrive2/autometa2_benchmarks/data/reads/78Mbp"

autometa-coverage \
    --assembly $assembly_dir/"metagenome.filtered.fna" \
    --fwd-reads $read_dir/"forward_reads.fastq.gz" \
    --rev-reads $read_dir/"reverse_reads.fastq.gz" \
    --cpus $cpus \
    --out $out_dir/"autometa-coverage.tsv"
    