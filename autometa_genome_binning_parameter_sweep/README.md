# Autometa genome binning parameter sweep

This document will outline how to setup Autometa benchmarking jobs on CHTC or a lab server.

## Getting Started

1. [Setup data directories and compute environment](#compute-environment-setup)
2. [Configure an Autometa command for benchmarking](#configuring-an-autometa-binning-command-for-benchmarking)
3. [Generate binning parameter sweep arguments file](#generate-binning-parameter-sweep-arguments-file)
4. [Submit jobs for configured command w/parameters file](#submit-jobs-using-parameters)
5. [Commands used for parameter sweep against CAMI2 datasets](#cami2-benchmarking-parameter-sweep)

Resources:

- [HTCondor Troubleshooting](autometa_genome_binning_parameter_sweep/HTCONDOR_TROUBLESHOOTING.md)

## Compute Environment Setup

HTCondor job submissions were implemented to take advantage of CHTC's parallelized compute resources.
The parameter sweep job submission (`autometa_parameter_sweep.sub`) references a command template
(`autometa_binning.sh`) as well as a parameters file (`sweep_parameters.txt`) which allows arguments
(like `--cluster_method DBSCAN`) to be supplied to `autometa-binning` in `autometa_binning.sh`. Prior
to job submission, a compute environment must be configured for use on the compute node.

There are two options available, either the compute node can download and run the command in a
provided docker image, or a compute environment may be constructed and tarballed to be transferred to
the compute node at runtime, where it will then need to be extracted and installed prior to running
the respective preprocessing or binning command.

### Autometa docker environment

Autometa is available on docker hub with multiple supported versions. If docker is available to you at your compute facility or on your lab's server, you may easily specify the docker image tag you wish to use proceed with configuring the command and parameter sweep arguments file.

```bash
# lines in autometa_parameter_sweep.sub
universe = docker
docker_image = jasonkwan/autometa:2.2.0
```

#### Image tags

##### Branches & Latest (less stable)

- `jasonkwan/autometa:latest` # latest commit from `main` branch
- `jasonkwan/autometa:dev` # up to date with `dev` branch
- `jasonkwan/autometa:main` # up to date with `main` branch

##### Releases (stable)

- `jasonkwan/autometa:2.2.0`
- `jasonkwan/autometa:2.1.0`
- `jasonkwan/autometa:2.0.3`
- `jasonkwan/autometa:2.0.2`
- `jasonkwan/autometa:2.0.1`
- `jasonkwan/autometa:2.0.0`

### Autometa conda environment

> NOTE: This is _NOT_ needed if the submit file uses the `docker` universe with a specified docker
> image.

Autometa's compute environment may be transferred and installed to CHTC's compute node to be used
when the respective job is running. This requires additional steps in the job's command template to
setup and teardown the compute environment. An example of packaging your own compute environment as well as setup and teardown at runtime and after termination of the job is outlined below.

#### 1. Create env tarball

In the following example, I have created the compute env (`autometa.tar.gz`) and have specified to
transfer this as an input file in `autometa_parameter_sweep.sub`

```bash
# Install mamba (faster and same commands available)
conda install -n base -c conda-forge mamba -y
# Create autometa env
mamba create -n autometa -c conda-forge -c bioconda autometa -y
# Create conda-pack env
mamba create -n conda-pack conda-pack -y
# package autometa env to tarball for transfer to SQUID web proxy
mamba activate conda-pack
conda-pack -n autometa
```

#### 2. Point to compute env tarball in submit file

After you have tarballed your compute environment, you may specify it in the submit file.

```bash
# lines in autometa_parameter_sweep.sub
universe = vanilla
http://proxy.chtc.wisc.edu/SQUID/erees/autometa.tar.gz
```

#### 3. Setup and teardown environment within command template

Next you will need to setup add the following code blocks to the beginning and end of the command 
template.

##### At beginning

```bash
## BEGIN conda env setup
# replace env-name on the right hand side of this line with the name of your conda environment
ENVNAME=autometa
# if you need the environment directory to be named something other than the environment name, change this line
ENVDIR=$ENVNAME

# these lines handle setting up the environment; you shouldn't have to modify them
export PATH
mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
. $ENVDIR/bin/activate

## END conda env setup
```

Now add the following to the end of the executable file defined in the submit file (for example
`autometa_binning.sh`)

```bash
# BEGIN conda env teardown
rm -rf $ENVDIR
rm -rf $ENVNAME.tar.gz
# END conda env teardown
```

> NOTE: If you are unsure about your executable, look for the following lines in your submit file:
>
> ```bash
> # line in autometa_parameter_sweep.sub
> executable = ./autometa_binning.sh
> ```

## Configuring an Autometa-binning command for benchmarking

Templates correspond to their process and process env, for example `autometa_binning_conda_env.sh` is
a template for the `autometa-binning` command using a conda environment.

> NOTE: For more information on setting up the appropriate compute environments, see 
> [Compute Environment Setup](#compute-environment-setup).

```console
templates/
├── autometa_binning_conda_env.sh
├── autometa_binning_docker_env.sh
├── autometa_binning_ldm_conda_env.sh
├── autometa_gc_content_docker_env.sh
├── autometa_kmers_docker_env.sh
└── autometa_taxonomy_docker_env.sh
```

## Generate binning parameter sweep arguments file

The following parameters were combined to generate parameter sweep results.

|   Parameter Sweep Parameters  |               Values               |     Process    |               Entrypoints              |
|:-----------------------------:|:----------------------------------:|:--------------:|:--------------------------------------:|
|         Cluster Method        |           DBSCAN, HDBSCAN          | Genome-binning | autometa-binning, autometa-binning-ldm |
|          Completeness         | 10, 20, 30, 40, 50, 60, 70, 80, 90 | Genome-binning | autometa-binning, autometa-binning-ldm |
|             Purity            | 10, 20, 30, 40, 50, 60, 70, 80, 90 | Genome-binning | autometa-binning, autometa-binning-ldm |
| GC Content standard deviation |            2, 5, 10, 15            | Genome-binning | autometa-binning, autometa-binning-ldm |
|  Coverage standard deviation  |            2, 5, 10, 15            | Genome-binning | autometa-binning, autometa-binning-ldm |
|       k-mer norm. method      |              ILR, CLR              | Genome-binning |          autometa-binning-ldm          |
|       k-mer embed method      |            BH-tSNE, UMAP           | Genome-binning |          autometa-binning-ldm          |
|       taxonomy database       |             NCBI, GTDB             |  Taxon-binning |            autometa-taxonomy, autometa-taxonomy-lca, autometa-taxonomy-majority-vote            |

### The `sweep_parameters.txt` file format

The input parameters file format should contain one set of job arguments per line.
These job arguments are defined in the `autometa_parameter_sweep.sub` to be passed to `autometa_binning.sh`

>`sweep_parameters.txt` ➡️ `autometa_parameter_sweep.sub` ➡️ `autometa_binning.sh`.

#### Generating parameter combinations with `scripts/generate_param_sweep_list.py`

`--input` is a path to your data directory containing one metagenome per sub-directory.

The directory structure should resemble something like this:

```console
data
├── cami
│   ├── marmgCAMI2_short_read_pooled_gold_standard_assembly
│   │   ├── logs
│   │   └── preprocess
│   ├── marmgCAMI2_short_read_pooled_megahit_assembly
│   │   ├── logs
│   │   └── preprocess
│   ├── strmgCAMI2_short_read_pooled_gold_standard_assembly
│   │   ├── logs
│   │   └── preprocess
│   └── strmgCAMI2_short_read_pooled_megahit_assembly
│       ├── logs
│       └── preprocess
└── databases
    └── ncbi

```

With this directory structure, you can pass a regex pattern `*assembly` to retrieve the metagenome sub-dirs for the parameter sweep analysis:

> NOTE: The `--glob` uses the regex value to find sub-directories on the `--input` directory path.

Here is an example command for the CAMI2 datasets using the directory structure shown above...

```bash
python scripts/generate_param_sweep_list.py \
    --input $HOME/data/cami \ 
    --glob "*assembly"
    --output cami_sweep_parameters.txt
```

... and here is the breakdown of the search path:

|     `--input`     |   `--glob`  | `code`                                                | search string                    | Example values for `communityDir` in submit file                                                                                                                                                    |
|:-----------------:|:-----------:|-------------------------------------------------------|----------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `$HOME/data/cami` | `*assembly` | `os.path.join(args.input, args.glob, recursive=True)` | `/home/user/data/cami/*assembly` | marmgCAMI2_short_read_pooled_gold_standard_assembly marmgCAMI2_short_read_pooled_megahit_assembly strmgCAMI2_short_read_pooled_gold_standard_assembly strmgCAMI2_short_read_pooled_megahit_assembly |

> This will allow use of `queue <var> from <arglist>` in submit file. e.g.:
>
>```bash
>queue communityDir,community,cluster_method,completeness,purity,cov_stddev_limit,gc_stddev_limit from cami_sweep_parameters.txt
>```

##### Example output

```bash
(autometa) [erees@submit-1 binning_param_sweep]$ python generate_param_sweep_list.py --input /home/erees/autometa_runs/binning_param_sweep/data/cami --glob "*assembly" --output cami2_sweep_parameters.txt
Found 4 communities
Wrote 10,368 (2,592 per community) parameter sweep jobs to cami2_sweep_parameters.txt
Wrote parameters in the format:
communityDir, community, cluster_method, completeness, purity, cov_stddev_limit, gc_stddev_limit
----------------------------------------------------------------------------------------------------
PLACE the following in your submit file using these parameter combinations:
queue communityDir,community,cluster_method,completeness,purity,cov_stddev_limit,gc_stddev_limit from cami2_sweep_parameters.txt
```

## Submit jobs using parameters

### Items to double-check prior to submission

1. inputs for executable (`autometa_binning.sh`) match filenames transferred in `*.sub` file (listed
in `transfer_input_files`)
2. Check directories exist where `stderr`, `stdout`, and `log` will be written (NOTE: These will be
written relative to `initial_dir`, e.g. `communityDir`)
3. Check annotation files are in their correct location. i.e.
`communityDir/preprocess/<annotation_file>`

Each `preprocess` directory should contain annotation files required as input to their respective
command.

Here is one example corresponding to the `autometa-binning` command template:

```console
preprocess
├── 5mers.am_clr.bhsne.tsv
├── taxonomy.tsv
├── bacteria.markers.tsv
├── coverage.tsv
└── gc_content.tsv
```

#### Parameter sweep genome binning

```bash
condor_submit autometa_parameter_sweep.sub
```

##### Taxonomy pre-processing

> to test an interactive job:
>
> ```bash
> condor_submit -i autometa_preprocess_taxonomy_test.sub
> ```

```bash
condor_submit autometa_preprocess_taxonomy.sub
```

#### CAMI2 datasets

##### Parameter sweep autometa-binning

```bash
condor_submit cami_genome_binning_parameter_sweep.sub
```

##### Parameter sweep autometa-binning-ldm

```bash
condor_submit cami_autometa_ldm_binning_parameter_sweep.sub
```

test interactive job

```bash
condor_submit -i cami_autometa_binning_large_data_mode_parameter_sweep_w_kmer_args_test.sub
```

```bash
condor_submit cami_autometa_binning_large_data_mode_parameter_sweep_w_kmer_args.sub
```

## CAMI2 benchmarking parameter sweep

### specific steps for CAMI2 datasets

1. [Preprocess CAMI2 data](#1-preprocess-cami2-data)
2. [Generate parameters](#2-generate-cami2-parameters-for-queue-in-cami_genome_binning_parameter_sweepsub)
3. [Submit jobs to HTCondor](#3-submit-cami2-parameter-sweep-jobs-htcondor)
4. [Convert binning results to biobox format](#4-formatting-autometa-2-results-to-biobox-format)
5. [Run AMBER on biobox-formatted binning results](#5-benchmark-autometa-2-results-with-cami2-submissions-using-amber)
6. [Get runtime and memory usage information](#6-retrieve-runtime-information-from-htcondor-logs-for-cami-parameter-sweeps)

### 1. Preprocess CAMI2 data

The CAMI2 assemblies were first pre-processed prior to performing genome-binning. This was performed
on the lab server using nextflow and so the corresponding commands are listed below.

>NOTE: Some metaBenchmarks workflows use Autometa modules for pre-processing.
>
>To import the Autometa modules for use with the metaBenchmarks workflows, run:
>
>```bash
>nextflow clone kwanlab/Autometa
>```

pre-processing generates annotations for each CAMI2 dataset. The annotations are:

1. contig lengths & GC content
2. contig read (or k-mer) coverage
3. kmers
4. markers
5. taxonomy

```bash
cd ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/
nextflow run cami_preprocess.nf -resume -c cami.config -profile slurm -w cami_work
```

This will generate sub-directories corresponding to `${params.outdir}/${meta.id}/preprocess`.

### 2. Generate CAMI2 parameters for `queue` in `cami_genome_binning_parameter_sweep.sub`

The output directory specified in `cami.config` from step 1:

```groovy
params.outdir = "nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"
```

#### Transfer pre-processing results to CHTC

```bash
OUTDIR="${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"
CHTC_DIR="/home/erees/autometa_runs/binning_param_sweep/data"
# Transfer directories and files to CHTC
rsync -azPL $OUTDIR chtc:"${CHTC_DIR}/."
```

#### Generate parameters for CHTC job submission

```bash
# On CHTC (rsync)
cd /home/erees/autometa_runs/binning_param_sweep
python generate_param_sweep_list.py \
  --input data/cami/ \
  --glob "*assembly" \
  --output cami2_sweep_parameters.txt
```

### 3. Submit CAMI2 parameter sweep jobs (HTCondor)

```bash
# Navigate to directory
cd /home/erees/autometa_runs/binning_param_sweep
# Submit CAMI2 jobs
condor_submit cami_genome_binning_parameter_sweep.sub
```

### 4. Formatting autometa 2 results to biobox format

#### Transfer autometa2 CAMI2 binning results back to server

```bash
OUTDIR="${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"
CHTC_DIR="/home/erees/autometa_runs/binning_param_sweep/data"
# Transfer autometa2 results from CHTC
rsync -azPL chtc:"${CHTC_DIR}/cami/" "${OUTDIR}/"
```

#### Format Autometa 2 CAMI2 binning results into biobox format for AMBER tool

```bash
bash ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/format_autometa_cami_binning_tables_to_biobox_format.sh
```

### 5. Benchmark Autometa 2 results with CAMI2 submissions using AMBER

#### Marine GSA

##### bash

```bash
bash ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_marine_gsa_results.sh
```

##### SLURM

```bash
sbatch ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_marine_gsa_results.sh
```

#### Marine megahit

##### bash

```bash
bash ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_marine_megahit_results.sh
```

##### SLURM

```bash
sbatch ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_marine_megahit_results.sh
```

#### Strain Madness GSA

##### bash

```bash
bash ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_strmgCAMI2_short_read_pooled_gsa_assembly.sh
```

##### SLURM

```bash
sbatch ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_strmgCAMI2_short_read_pooled_gsa_assembly.sh
```

#### Strain Madness megahit

> NOTE: Ground truth files were retrieved from the CAMI2 paper github repository:
> https://github.com/CAMI-challenge/second_challenge_evaluation/

0. clone CAMI2 evaluation repo to get ground truths

```bash
git clone https://github.com/CAMI-challenge/second_challenge_evaluation.git
```

1. Untar megahit binning ground truth (only needs to be performed once)

```bash
cd $HOME/second_challenge_evaluation/binning/genome_binning/strain_madness_dataset/data/ground_truth
tar -xvzf strain_madness_megahit.binning.tar.gz
```

##### bash

```bash
bash ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_strmgCAMI2_short_read_pooled_megahit_assembly.sh
```

##### SLURM

```bash
sbatch ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/amber_autometa_genome_binning_strmgCAMI2_short_read_pooled_megahit_assembly.sh
```

All AMBER outputs may be found here: `ls -d ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/*assembly/genome_binning/amber-output`

### 6. Retrieve runtime information from HTCondor logs for CAMI parameter sweeps

```bash
REPO="$HOME/metaBenchmarks"
script="${REPO}/autometa_genome_binning_parameter_sweep/scripts/parse_log_runtime_information.py"
indir="${REPO}/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami"
python $script --input $indir --output cami_runtime_info.tsv.gz
```

## CAMI2 autometa GTDB integration benchmarking

### Format autometa binning tables to biobox format

```bash
bash /media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/scripts/format_autometa_gtdb_genome_binning_to_biobox_format.sh
```

### Run AMBER

```bash
bash /media/BRIANDATA4/metaBenchmarks/autometa_genome_binning_parameter_sweep/scripts/amber_autometa_gtdb_genome_binning_results.sh
```
