# Taxon binning benchmarking

## Modules

- Autometa v1.0.3
- Autometa v2.0.2
- mmseqs2
- kraken2
- diamond

## Benchmark

First locate taxon binning directory

```bash
# For example...
cd ${HOME}/metaBenchmarks/taxon-binning
```

Run nextflow benchmarking for taxon-binning with `taxon-binning-benchmarks` env (`conda activate taxon-binning-benchmarks`).

See [Setup](#setup) for details on configuring the `taxon-binning-benchmarks` compute environment

```bash
nextflow run main.nf -c simulated.config -profile slurm -resume
```

## Setup

1. [create env](#create-env)
2. [activate env](#activate-env)
3. [build autometa v1.0.3 docker image](#create-env-for-autometa-v103)

### Create env

```bash
conda env create -f=environment.yml
```

### Activate env

```bash
conda activate taxon-binning-benchmarks
```

### Create env for Autometa v1.0.3

#### 1. Build docker image

```bash
docker build \
    git@github.com:KwanLab/Autometa.git#c85ab9673345f62e9d6a7e1aecb2d1c4e1b0c598 \
    -t jasonkwan/autometa:1.0.3
```

Now setup `autometa_v1` env specifically for nextflow execution

#### 2. Install `procps` in built docker image

```bash
# 1. Run a container
docker run --rm -it jasonkwan/autometa:1.0.3
# 2. Install procps in container
apt-get update && apt install -y procps && apt-get clean
# Keep container running...
```

#### 3. Commit container as new image

(Open a new terminal to tag the running container)

```bash
# 3. Check that container is still running and get container ID
docker ps -a
# 4. Commit container to image name with procps installed
# My container ID ended up being 24c4931c82a5
docker commit -m "Add procps for nextflow execution" 24c4931c82a5 jasonkwan/autometa:1.0.3
```

### AMBER docker image creation

```bash
docker build taxon_binning/docker/amber -f taxon_binning/docker/amber/Dockerfile -t cami-challenge/amber
```

#### Running AMBER on Autometa taxon_binning CAMI2 results

```bash
cami_samples=(marmgCAMI2_short_read_pooled_gold_standard_assembly \
    marmgCAMI2_short_read_pooled_megahit_assembly \
    strmgCAMI2_short_read_pooled_gold_standard_assembly \
    strmgCAMI2_short_read_pooled_megahit_assembly)

for sample in ${cami_samples};do
    if [[ $sample == *"strmg"* ]]; then
        ground_truths="${HOME}/metaBenchmarks/data/cami/strain_madness/ground_truth"
        assembly="gsa_pooled_mapping.binning"
        # if [[ $sample == *"gold_standard"* ]]; then
        #     assembly="gsa_pooled_mapping.binning"
        # else
        #     assembly="strain_madness_megahit.binning"
        # fi
    else
        ground_truths="${HOME}/metaBenchmarks/data/cami/marine/ground_truth"
        assembly="gsa_pooled_mapping_short.binning"
        # if [[ $sample == *"gold_standard"* ]]; then
        #     assembly="gsa_pooled_mapping_short.binning"
        # else
        #     assembly="marine_megahit.binning"
        # fi
    fi
    results="${HOME}/metaBenchmarks/taxon-binning/nf-taxon-binning-benchmarks/${sample}"
    ncbiDir="${HOME}/metaBenchmarks/data/cami/databases"
    docker run --rm \
        -v $results:/results:rw \
        -v $ground_truths:/ground_truths:ro \
        -v $ncbiDir:/ncbi:rw \
        --user=$(id -u):$(id -g) \
        cami-challenge/amber \
        --gold_standard_file ground_truths/$assembly \
        --output_dir /results/amber-output \
        --ncbi_dir /ncbi \
        /results/${sample}.autometa_v2.taxonomy.binning
done
```

### OPAL docker image creation

```bash
docker build taxon-binning/docker/opal -f taxon-binning/docker/opal/Dockerfile -t cami-challenge/opal
```
