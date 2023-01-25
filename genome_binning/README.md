# Genome Binning Benchmarking

## Modules

1. Autometa v2 large-data-mode (Separate process, see `${HOME}/metaBenchmarks/autometa_binning_parameter_sweep`)
2. Autometa v2 (Separate process, see `${HOME}/metaBenchmarks/autometa_binning_parameter_sweep`)
3. Autometa v1 (Separate process, see `${HOME}/metaBenchmarks/autometa_binning_parameter_sweep`)
4. MaxBin2
5. MetaBat2
6. MyCC (Not operational)
7. VAMB

## Compute environment setup

### Create `genome-binning-benchmarks` environment

```bash
conda env create -f=environment.yml
```

```bash
conda activate genome-binning-benchmarks
```

### Clone Autometa nextflow repo

The Autometa nextflow repo will be used to prepare the input datasets for the binners to be benchmarked..

```bash
REPO="${HOME}/metaBenchmarks"
nextflow clone -r 2.1.0 KwanLab/Autometa $REPO/genome_binning/
```

## Databases setup

NOTE: ~1.4 TB of databases required for all tools (genome and taxon binners)

## Simulated data download

NOTE: If specifying a subset of community sizes, you must separate the choices by a whitespace.

### Download forward and reverse reads

```bash
REPO="${HOME}/metaBenchmarks"
autometa-download-dataset \
    --community-type simulated \
    --community-sizes all \
    --file-names forward_reads.fastq.gz reverse_reads.fastq.gz \
    --dir-path "${REPO}/data/reads/simulated"
```

### Download assemblies and reference assignments

```bash
REPO="${HOME}/metaBenchmarks"
autometa-download-dataset \
    --community-type simulated \
    --community-sizes all \
    --file-names reference_assignments.tsv.gz metagenome.fna.gz \
    --dir-path "${REPO}/data/assemblies/simulated"
```

## Dataset preparation

Binners require assemblies and coverage information.

The coverage information may be specified in a variety of formats, so prior to running the genome binners,
these formats must be generated. The Autometa v2 nextflow workflow contains a sub-workflow
`CONTIG_COVERAGE` to generate coverage information from read alignments.
This also generates the intermediate files (alternate formats) required for the various genome binners as input.

We will use this subworkflow to generate the various coverage calculation files for our inputs for each of our datasets.

<https://github.com/KwanLab/Autometa/blob/main/subworkflows/local/contig_coverage.nf>

## Running the `genome-binning-benchmarks` workflow on simulated communities

```bash
nextflow run . -c simulated.config -profile slurm -resume
```

## Semi-manual benchmarks creation

The MyCC binning run on the 5000Mbp community generated intermediate files amounting to 2.1TB, filling the disk and causing the nextflow workflow to fail.

The MyCC run was retried twice more, without any results... To this, we have added the `disk '100 GB'` directive to each binning process, so these jobs are killed before
filling up the disk.

In the mean time, genome binning results were transferred and benchmarked using the following commands:

```bash
# Create directories to store binning results and benchmarks
mkdir -p ${HOME}/metaBenchmarks/genome_binning/data/{genome_binning,benchmarks}
# find results then copy to data/genome_binning directory
for f in `find work/ -name "*Mbp.*.binning.tsv"`;do
    rsync -azPL $f data/genome_binning/$(basename $f);
done
# benchmark results by community
for community in 78Mbp 156Mbp 312Mbp 625Mbp 1250Mbp 2500Mbp 5000Mbp 10000Mbp;do
    reference="${HOME}/metaBenchmarks/data/assemblies/simulated/${community}/reference_assignments.tsv.gz"
    predictions=$(ls data/genome_binning/${community}.*.binning.tsv)
    autometa-benchmark \
        --benchmark binning-classification \
        --predictions $predictions \
        --reference $reference \
        --output-wide data/benchmarks/${community}.binning_classification_benchmarks.wide.tsv
done
```

Benchmarks may be found at: `${HOME}/metaBenchmarks/genome_binning/data/benchmarks`

## Alignment mystery

**(hopefully) solved :eyes::mag:**

### Alignments overview of previous reads sets

Upon inspection of the previous runs, all of the datasets VAMB results as well as MyCC results were empty.
VAMB encountered an error (implementation oversight, but this is resolved now), while MyCC did not emit any errors.
MyCC was returning empty results. No clusters were recovered for 7/8 of the communities where it successfully ran.
To inspect what could be going wrong, the work sub-directory was searched for the input files.
The only difference between the 78Mbp test run and the benchmarking run was the input coverage table.
Many of the contigs within the coverage table had 0x coverage.
If we quickly assess the overall alignment rates for each of our datasets, we get the following:

```bash
for f in `grep -l "overall alignment rate"  ${HOME}/metaBenchmarks/genome_binning/work/*/*/.command.err`;do
    workdir=$(dirname $f);
    raw=$(ls $workdir/*.db.1.bt2);
    community=$(basename $(echo ${raw/.db.1.bt2/}));
    alnRate=$(grep "overall alignment rate" $f);
    echo $community ${alnRate/overall alignment rate/}
done | sort -n | uniq
```

> Output

```text
78Mbp 98.04%
156Mbp 1.61%
312Mbp 2.99%
625Mbp 12.52%
1250Mbp 17.29%
2500Mbp 28.27%
5000Mbp 39.17%
10000Mbp 9.97%
```

From above it appears only the 78Mbp community had decent alignments. There arises a suspicion as to whether the reads
aligned to the metagenome assemblies were actually the reads that were used for the assembly of these metagenomes.
There are other reads files that appear to (based on their file names) correspond to these communities.
To determine which set of reads is most appropriate, alignments will be performed and the workflow re-run.
The overall alignment rates will again be determined to assess if these reads align better than the previous reads set.

There is still a bit of mystery here, as MyCC *should* have recovered genomes from the 78Mbp dataset,
although it failed to recover any clusters. The coverage table is not sparse as you would expect of
the other datasets. So here, we will dig a little deeper...

```bash
(binning-benchmarks) evan@userserver:${HOME}/metaBenchmarks/genome_binning$ find ${HOME}/metaBenchmarks/genome_binning/work/ -name "78Mbp.mycc.*"
```

This gives us four genome binning results files where we can inspect the nextflow MyCC runtime logs.

```text
work/c4/18b2b9874b338e6e216162dfa08ad9/78Mbp.mycc.binning.tsv
work/00/c0584d11741bb5843ad69954db831e/78Mbp.mycc.binning.tsv
work/bc/f95d06b77f4dc54311edbccc86c818/78Mbp.mycc.binning.tsv
work/e3/9ee9d0af5f07f6dd97ab13b64c6f95/78Mbp.mycc.binning.tsv
```

Upon further inspection, really we are only working with 2 different genome binning results files.
One from April 5th and another from April 12th:

```bash
(binning-benchmarks) evan@userserver:${HOME}/metaBenchmarks/genome_binning$ find ${HOME}/metaBenchmarks/genome_binning/work/ -name "78Mbp.mycc.*" | xargs -I {} ls -lht {}
lrwxrwxrwx 1 evan storage 107 Apr 11 12:22 ${HOME}/metaBenchmarks/genome_binning/work/c4/18b2b9874b338e6e216162dfa08ad9/78Mbp.mycc.binning.tsv -> ${HOME}/metaBenchmarks/genome_binning/work/e3/9ee9d0af5f07f6dd97ab13b64c6f95/78Mbp.mycc.binning.tsv
lrwxrwxrwx 1 evan storage 107 Apr 11 12:25 ${HOME}/metaBenchmarks/genome_binning/work/00/c0584d11741bb5843ad69954db831e/78Mbp.mycc.binning.tsv -> ${HOME}/metaBenchmarks/genome_binning/work/e3/9ee9d0af5f07f6dd97ab13b64c6f95/78Mbp.mycc.binning.tsv
-rw-r--r-- 1 evan evan 15 Apr 12 11:16 ${HOME}/metaBenchmarks/genome_binning/work/bc/f95d06b77f4dc54311edbccc86c818/78Mbp.mycc.binning.tsv
-rw-r--r-- 1 evan evan 15 Apr  5 10:13 ${HOME}/metaBenchmarks/genome_binning/work/e3/9ee9d0af5f07f6dd97ab13b64c6f95/78Mbp.mycc.binning.tsv
```

If we inspect the work directories of these runs:

```bash
ls -talh ${HOME}/metaBenchmarks/genome_binning/work/bc/f95d06b77f4dc54311edbccc86c818/ ${HOME}/metaBenchmarks/genome_binning/work/e3/9ee9d0af5f07f6dd97ab13b64c6f95/
```

### Test run of MyCC template

To ensure there is not an issue with the MyCC bash template, we'll try running this on one of our set of inputs in one of these work directories...

```bash
cd ${HOME}/metaBenchmarks/genome_binning/work/bc/f95d06b77f4dc54311edbccc86c818/

```

## Next Steps

```bash
nextflow run . -c simulated.new.config -profile slurm -resume -work-dir new_work
```

### Alignments with reads found on KwanLab server

Notes on the reads found on the Kwanlab server may be found here, `${HOME}/metaBenchmarks/data/reads/simulated/data_locations/README.md`.

The reads that were transferred and used for this nextflow run were located on the `kwanlab` server at `/media/box3/Dec-2016_IJM_simulated_metagenomes`.

Comparison of the checksums for these reads and the previously used reads differed,
suggesting one of these read sets was the more appropriate read set to
use for each respective metagenome. We will determine which read set is more
appropriate by comparison of the overall read alignments back to their respective
metagenome assembly.

An analysis of the previous reads sets can be viewed in the earlier section,
[Alignments overview of previous reads sets](#alignments-overview-of-previous-reads-sets)

```bash
newWorkDir="${HOME}/metaBenchmarks/genome_binning/new_work"
for f in `grep -l "overall alignment rate" ${newWorkDir}/*/*/.command.err`;do
    workdir=$(dirname $f);
    raw=$(ls $workdir/*.db.1.bt2);
    community=$(basename $(echo ${raw/.db.1.bt2/}));
    alnRate=$(grep "overall alignment rate" $f);
    echo $community ${alnRate/overall alignment rate/};
done | sort -n
```

```text
78Mbp 98.04%
156Mbp 98.40%
312Mbp 96.26%
625Mbp 98.03%
1250Mbp 97.41%
2500Mbp 94.68%
5000Mbp 73.00%
10000Mbp 11.32%
```

It appears from these alignments, the new reads (located at
`/media/box3/Dec-2016_IJM_simulated_metagenomes`) were likely the reads employed
for metagenome assembly. We will proceed with the benchmarking analyses using these
read sets. Also worth mentioning, the 78Mbp reads checksums were different across
all reads sets, where most of the other communities had redundancy across data
directories... The alignments for both 78Mbp communities also shared the same
overall alignment results, (i.e. `98.04% overall alignment rate`) so we will
continue with the 78Mbp reads located in `/media/box3/Dec-2016_IJM_simulated_metagenomes`.
