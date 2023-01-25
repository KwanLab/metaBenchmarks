# Metagenome Assemblies

- [Simulated Communities](#simulated-communities)
- [CAMI2](#cami2-assemblies)

## Simulated Communities

1. 78 Mbp
2. 156 Mbp
3. 325 Mbp
4. 650 Mbp
5. 1250 Mbp
6. 2500 Mbp
7. 5000 Mbp
8. 10000 Mbp

### Download

#### Install `autometa-download-dataset` command

```bash
# install autometa into env for download command
mamba create -n autometa -c bioconda autometa -y
# NOTE: You may use conda and mamba interchangeably
# To use mamba simply install in your conda base env
# conda install -n base mamba -y
```

```bash
# activate env
mamba activate autometa
```

#### Run `autometa-download-dataset` commmand

```bash
autometa-download-dataset \
    --community-type simulated \
    --community-sizes all \
    --file-names metagenome.fna.gz,reference_assignments.tsv.gz \
    --dir-path simulated
```

#### Simulated Communities Length-filter

A pre-processing length filter of 3kbp was applied. This was performed with the following code chunk:

```bash
for assembly in `ls simulated/*/*.fna.gz`;do
    filtered=${assembly/.fna.gz/.filtered.fna} # rename the (decompressed) length-filtered assembly
    echo "Applying length filter on: $assembly"
    autometa-length-filter --cutoff 3000 --assembly $assembly --output-fasta $filtered
done
```

## CAMI2 assemblies

NOTE: You will need to download a link file from the CAMI site to use the `camiClient.jar` with the respective `dataset.linkfile`.

Information on using `camiClient.jar` - <https://www.microbiome-cosi.org/cami/resources/cami-client>

CAMI Challenge website: <https://data.cami-challenge.org/participate>

### Marine dataset

```bash
java -jar cami/camiClient.jar \
    -d cami/strain_madness/strain_madness_assembly.linkfile \
    cami/strain_madness/ \
    --threads 4
```

### Strain Madness dataset

```bash
java -jar cami/camiClient.jar \
    -d cami/marine/marine_dataset_assembly.linkfile \
    cami/marine/ \
    --threads 4
```

### Rhizosphere dataset

```bash
java -jar cami/camiClient.jar \
    -d cami/rhizosphere/rhizosphere_dataset_assembly.linkfile \
    cami/rhizosphere/ \
    --threads 4
# Moving the assemblies to correspond with worfklow directory structure
# <cami/dataset/assembly.fasta.gz>
mv cami/rhizosphere/assembly/* cami/rhizosphere/.
rmdir cami/rhizosphere/assembly
```

#### CAMI Datasets Length-filter

cutoff = 3kbp

```bash
for assembly in `ls cami/*/*.fasta.gz`;do
    filtered=${assembly/.fasta.gz/.filtered.fna}
    echo "Applying length filter on: $assembly"
    autometa-length-filter --cutoff 3000 --assembly $assembly --output-fasta $filtered
done
```
