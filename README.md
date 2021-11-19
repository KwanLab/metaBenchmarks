
# Creating modules
## Background info
A lot of documentation exists but is directed mainly concerned with contributing new modules to the nf-core/modules repository.
    - https://nf-co.re/developers/tutorials/dsl2_modules_tutorial
    - https://github.com/nf-core/modules

I think the best resource for learning about the structure of modules and how they incorporate into workflows is the video
https://youtu.be/ggGGhTMgyHI?t=1172   , starting at 19:30 

It also looks like an additional helpful video will be released on September 7, 2021 : https://nf-co.re/events/2021/bytesize-19-dsl2-pipeline-starter

## Creating local modules for benchmarking
To add a new local module

Clone this repo and create a new branch to work on

Install `nf-core` using conda:

e.g. both nf-core and nextflow
```
conda create --name nf-core python=3.7 nf-core nextflow
```

Navigate to the `metaBenchmarks` directory.

To see if a module already exists from nf-core run:

```
nf-core modules list remote
```

If it exists you can install it using:
e.g. for `samtools/sort`

```
nfcore modules install nf-core modules list remote
```

If a module doesn't exist then create your own using

```
nf-core modules create
```

When prompted for `Name of tool/subtool:`, if, for example, you're creating a DIAMOND BLASTp module you would enter `diamond` when prompted.


Set all benchmarking processes `Process resource label` as `process_high`. This will allow providing all benchmark processes the same resources.

When prompted `Will the module require a meta map of sample information? (yes/no) [y/n] (y):` enter `y`




# Modules Information

## Autometa v1.0.2

Type: Binning of Contigs

Website:
https://github.com/KwanLab/Autometa/releases/tag/1.0.2


Inputs:
  - Nucleotide contigs
Outputs:

Code to run individual module:
```{bash}

```

## Maxbin2 v2.2.7

Type: Binning of Contigs

Website:
https://sourceforge.net/projects/maxbin2/

Inputs:
  - Nucleotide contigs
  - Reads files (forward and reverse, used to calculate abundance data)

Outputs:
maxbin2_output.001.fasta
maxbin2_output.002.fasta
maxbin2_output.003.fasta
maxbin2_output.004.fasta
maxbin2_output.abund1
maxbin2_output.abund2
maxbin2_output.abundance
maxbin2_output.log
maxbin2_output.marker
maxbin2_output.marker_of_each_bin.tar.gz
maxbin2_output.noclass
maxbin2_output.summary
maxbin2_output.tooshort

Code to run individual module (to run a module test script, cd to metaBenchmarks/ and run the test nextflow file from there):
```{bash}
nextflow run modules/local/tests/maxbin2_test.nf
```













---
# nf-core template readme:





# ![nf-core/benchmark](docs/images/nf-core-benchmark_logo.png)

[![GitHub Actions CI Status](https://github.com/nf-core/benchmark/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/benchmark/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/nf-core/benchmark/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/benchmark/actions?query=workflow%3A%22nf-core+linting%22)
[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/benchmark/results)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23benchmark-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/benchmark)
[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/nf_core)
[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->
**nf-core/benchmark** is a bioinformatics best-practice analysis pipeline for Benchmarking taxomonic profilers and metagenomic binners.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

<!-- TODO nf-core: Add full-sized test dataset and amend the paragraph below if applicable -->
On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources. The results obtained from the full-sized test can be viewed on the [nf-core website](https://nf-co.re/benchmark/results).

## Pipeline summary

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.04.0`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Download the pipeline and test it on a minimal dataset with a single command:

    ```console
    nextflow run nf-core/benchmark -profile test,<docker/singularity/podman/shifter/charliecloud/conda/institute>
    ```

    > * Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
    > * If you are using `singularity` then the pipeline will auto-detect this and attempt to download the Singularity images directly as opposed to performing a conversion from Docker images. If you are persistently observing issues downloading Singularity images directly due to timeout or network issues then please use the `--singularity_pull_docker_container` parameter to pull and convert the Docker image instead. Alternatively, it is highly recommended to use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to pre-download all of the required containers before running the pipeline and to set the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options to be able to store and re-use the images from a central location for future pipeline runs.
    > * If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Start running your own analysis!

    <!-- TODO nf-core: Update the example "typical command" below used to run the pipeline -->

    ```console
    nextflow run nf-core/benchmark -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> --input samplesheet.csv --genome GRCh37
    ```

## Documentation

The nf-core/benchmark pipeline comes with documentation about the pipeline [usage](https://nf-co.re/benchmark/usage), [parameters](https://nf-co.re/benchmark/parameters) and [output](https://nf-co.re/benchmark/output).

## Credits

nf-core/benchmark was originally written by  .

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#benchmark` channel](https://nfcore.slack.com/channels/benchmark) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  nf-core/benchmark for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->
An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
