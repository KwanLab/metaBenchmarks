# CAMI2 preprocessing notes & logs

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
