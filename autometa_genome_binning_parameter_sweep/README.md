# Autometa binning parameter sweep

Scaling Autometa parameter sweep on CHTC

## Table of Contents

1. [Simulated Community parameter sweep benchmarking]
2. [HTCondor Troubleshooting](autometa_genome_binning_parameter_sweep/HTCONDOR_TROUBLESHOOTING.md)

## Simulated Community parameter sweep benchmarking

### Runtime/Monitoring Notes

- 108 jobs for 78Mbp did not produce an output binning file
  - 105 of these were HDBSCAN jobs with a coverage std.dev. cutoff at 2%
  - 3 of these were test runs where the output parameter was incorrectly specified in the template causing the run to fail. (These were test runs prior to running the full parameter sweep)
- taxon-profiling (`autometa_preprocess_taxonomy.sub`) for 2500Mbp and 5000Mbp failed due to job time limit (re-submitted with `+LongJob = true`)

### Quickstart

#### Submit HTCondor jobs using parameters

`condor_submit autometa_parameter_sweep.sub`

### Index

- [Parameter Sweep Parameters](#parameter-sweep-parameters)
- [Binning](#binning)
- [HTCondor Resources](#htcondor-resources)

### Parameter Sweep parameters

### Generate list of parameters

`python generate_param_sweep_list.py --input data --glob "*Mbp" --output sweep_parameters.txt`

> This will allow use of `queue <var> from <list>` in HTCondor submit file. e.g.:
> (at the bottom of the submit script)
> `queue cluster_method,completeness,purity,cov_stddev_limit,gc_stddev_limit from sweep_parameters.txt`

## CAMI2 parameter sweep benchmarking

### CAMI2 Preprocessing

```bash
nextflow run cami_preprocess_coverage.nf -resume -c cami.config -profile slurm
```

```bash
nextflow run cami_preprocess_metagenome.nf -resume -c cami.config -profile slurm
```

```bash
(base) evan@userserver:$HOME/autometa2_benchmarks/autometa_genome_binning_parameter_sweep$ for f in `find . -name "*CAMI2*alignments.sam"`;do workDir=$(dirname $f); log="${workDir}/.command.log"; echo "$f";grep "overall alignment rate" $log; done
./work/5b/42af01f5bc7af5a83f523ff48d86e6/marmgCAMI2_short_read_pooled_gold_standard_assembly.alignments.sam
96.58% overall alignment rate
./work/7b/eef6af771dbc4341a9e8e26253d823/strmgCAMI2_short_read_pooled_megahit_assembly.alignments.sam
45.42% overall alignment rate
./work/e1/d83d1726b89179082046ba4fbea34b/marmgCAMI2_short_read_pooled_megahit_assembly.alignments.sam
81.49% overall alignment rate
```

### Command using bowtie2 output (`alignments.sam`) to `coverage.tsv` step

Workflow had a typo resulting in `autometa-coverage` command to fail. By specifying the current directory
when passing `--out ./coverage.tsv` 

```bash
# conda activate autometa
# OR
# conda activate binning-benchmarks
# Run fixed command echoed by the following stdout
grep autometa-coverage .command.sh | sed -e 's,coverage.tsv,./coverage.tsv,g' .command.sh
``` 

```bash
(autometa) evan@userserver:$HOME/autometa2_benchmarks/autometa_genome_binning_parameter_sweep/work/d0/697e185fcaa95564577b9e87825ac9$ autometa-coverage     --cpus 48     --assembly strmgCAMI2_short_read_pooled_gold_standard_assembly.filtered.fna     --sam alignments.
sam     --bam alignments.bam     --bed alignments.bed     --out ./coverage.tsv
06/15/2022 11:00:50 AM : autometa.common.coverage : DEBUG : starting coverage calculation sequence from sam_exists
06/15/2022 11:00:50 AM : autometa.common.coverage : DEBUG : running sort_samfile
06/15/2022 11:00:50 AM : autometa.common.external.samtools : DEBUG : cmd: samtools view -@48 -bS alignments.sam | samtools sort -@48 -o /tmp/tmpb2axojzp/alignments.bam
06/15/2022 12:21:48 PM : autometa.common.coverage : DEBUG : running make_bed
06/15/2022 01:35:18 PM : autometa.common.coverage : DEBUG : running parse_bed
06/15/2022 01:35:25 PM : autometa.common.external.bedtools : DEBUG : ./coverage.tsv written
06/15/2022 01:35:25 PM : autometa.common.external.bedtools : DEBUG : coverage.tsv shape: (26095, 3)
06/15/2022 01:35:25 PM : autometa.common.utilities : INFO : get took 9274.87 seconds
```

### CAMI2 HTCondor Job submission

`python generate_param_sweep_list.py --input data/cami/ --glob "*assembly" --output cami2_sweep_parameters.txt`

## HTCondor Resources

- [Hello world example](https://chtc.cs.wisc.edu/uw-research-computing/helloworld.html#1-lets-first-do-and-then-ask-why)
- [More information on special variables like "$1", "$2", and "$@"](https://swcarpentry.github.io/shell-novice/06-script/index.html)
- [HTCondors DAGman](https://htcondor.readthedocs.io/en/latest/users-manual/dagman-workflows.html#dag-submission)
- [multiple jobs with initialdir](https://chtc.cs.wisc.edu/uw-research-computing/multiple-jobs.html#initialdir)
- [multiples jobs with queue <var> from <list>](https://chtc.cs.wisc.edu/uw-research-computing/multiple-jobs.html#foreach)
- [CHTC Squid Proxy for file transfer](https://chtc.cs.wisc.edu/uw-research-computing/file-avail-squid.html)
- [Create a portable python installation with miniconda](https://chtc.cs.wisc.edu/uw-research-computing/conda-installation.html#option-1-pre-install-miniconda-and-transfer-to-jobs)
- [Open Science Grid](https://github.com/opensciencegrid/cvmfs-singularity-sync/pull/368#event-6628051950)
- [OSG locations tutorial](https://github.com/OSGConnect/tutorial-osg-locations)
- [Map Customizer](https://www.mapcustomizer.com/) (coordinates imported from OSG locations tutorial)
- [Finding OSG Locations](https://support.opensciencegrid.org/support/solutions/articles/12000061978-finding-osg-locations)
- [Scaling beyond local HTC capacity](https://chtc.cs.wisc.edu/uw-research-computing/scaling-htc.html#uw)

## CAMI2 benchmarking parameter sweep

### 1. Preprocess CAMI2 data

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

1. Untar megahit binning ground truth (only needs to be performed once)

```bash
cd /media/BRIANDATA4/second_challenge_evaluation/binning/genome_binning/strain_madness_dataset/data/ground_truth
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
cd ${HOME}/metaBenchmarks/autometa_genome_binning_parameter_sweep
python parse_log_runtime_information.py --input nf-autometa-genome-binning-parameter-sweep-benchmarking-results/cami/ --output cami_runtime_info.tsv
```
