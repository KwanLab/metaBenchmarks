# CHTC

HTCondor job submissions were implemented to take advantage of CHTC's parallelized compute resources.
The parameter sweep job submission (`autometa_parameter_sweep.sub`) references a template entrypoint (`autometa_binning.sh`) as
well as a parameters file (`sweep_parameters.txt`) which allows arguments (like `--cluster_method DBSCAN`) to be supplied to `autometa-binning`.

## Getting Started for HTCondor

1. [Generate parameter sweep parameters](#parameter-sweep-parameters)
2. [Submit jobs using parameters](#submit-jobs-using-parameters)
3. [Benchmark results using AMBER](#classification-performance-evaluation)

### Submit jobs using parameters

#### Items to double-check prior to submission

1. inputs for executable (`autometa_binning.sh`) match filenames transferred in `*.sub` file (listed in `transfer_input_files`)
2. Ensure directories exist where `stderr`, `stdout`, and `log` will be written (NOTE: These will be written relative to `initial_dir`, e.g. `communityDir`)

#### Simulated community

```bash
condor_submit autometa_parameter_sweep.sub
```

##### Taxonomy pre-processing

test interactive job

```bash
condor_submit -i autometa_preprocess_taxonomy_test.sub
```

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

## Classification Performance Evaluation

### Biobox format

Convert biobox autometa binning formats (`*.binning.tsv`) formats to (`*.binning`)

```bash
# Input: Directories with string *assembly/*.binning.tsv
bash scripts/format_autometa_cami_binning_tables_to_biobox_format.sh
# Output: Results directory
# /media/BRIANDATA4/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/${sample}/genome_binning/
```

### AMBER

#### Marine GSA

```bash
bash scripts/amber_autometa_genome_binning_marine_gsa_results.sh
```

#### Marine Megahit

```bash
bash scripts/amber_autometa_genome_binning_marine_megahit_results.sh
```

#### Strain Madness GSA

```bash
bash scripts/amber_autometa_genome_binning_strmgCAMI2_short_read_pooled_gsa_assembly.sh
```

#### Strain Madness Megahit

```bash
bash scripts/amber_autometa_genome_binning_strmgCAMI2_short_read_pooled_megahit_assembly.sh
```

## Clustering Performance Evaluation

Convert biobox (`*.binning`) formats to autometa binning format (`*.binning.tsv`)

```bash
bash scripts/get_cami2_genome_binning_clustering_metrics.sh
```

## Runtime/Disk Usage

```bash
python scripts/parse_log_runtime_information.py \
    --input nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/ \
    --output cami2_param_sweep_jobs_runtime_info.tsv
```

## Binning

```groovy
process AUTOMETA_V2 {
    publishDir "${params.outdir}/${meta.id}/autometa_v2", mode: "${params.publish_dir_mode}"
    tag "${meta.id} ${cluster_method} comp:${completeness} pur:${purity} cov:${cov_stddev_limit} gc:${gc_stddev_limit}"

    cpus { params.cpus * task.attempt }
    memory { 16.GB * task.attempt }

    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'ignore' }

    input:
        tuple val(meta), path(kmers), path(coverage), path(gc_content), path(markers), path(taxonomy), val(cluster_method), val(completeness), val(purity), val(cov_stddev_limit), val(gc_stddev_limit)
    
    output:
        tuple val(meta), path("${meta.id}.autometa_v2.${cluster_method}.comp${completeness}.pur${purity}.cov${cov_stddev_limit}.gc${gc_stddev_limit}.binning.tsv")

    script:
        template 'autometa_v2.sh'
}
```
