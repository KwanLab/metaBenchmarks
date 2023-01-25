# Databases

## Table of Contents

- [CAMI2](#cami2)
- [Formatting latest databases for other datasets](#formatting-latest-databases-for-other-datasets)

## CAMI2

### Formatting CAMI databases

The CAMI2 databases were downloaded from https://data.cami-challenge.org/participate

It is important to note that the marine and strain madness datasets use the same CAMI ncbi databases.

#### marine & strain madness databases

Please use the following CAMI 2 challenge databases for the profiling and taxonomic binning challenge.
(also listed on the Databases tab):

- Blast nr: `https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_2_DATABASES/ncbi_blast/nr.gz`
- Blast nt: `https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_2_DATABASES/ncbi_blast/nt.gz`
- NCBI Taxonomy: `https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_2_DATABASES/ncbi_taxonomy.tar`
- Accession to Taxid Mapping: `https://openstack.cebitec.uni-bielefeld.de:8080/swift/v1/CAMI_2_DATABASES/ncbi_taxonomy_accession2taxid.tar`

#### Formatting with diamond

```bash
REPO="$HOME/metaBenchmarks"
CAMI="${REPO}/data/databases/cami"
mkdir -p "${CAMI}/diamond"
diamond makedb \
    --in "${CAMI}/nr.gz" \
    --db "${CAMI}/diamond/nr_with_taxonomy" \
    --taxonmap "${CAMI}/prot.accession2taxid.gz" \
    --taxonnodes "${CAMI}/nodes.dmp" \
    --taxonnames "${CAMI}/names.dmp"
```

> Example output from `diamond makedb` command

```console
Database sequences                   184124794
Database letters                     67182734252
Accessions in database               612278963
Entries in accession to taxid file   628458607
Database accessions mapped to taxid  611827407
Database sequences mapped to taxid   184018689
Database hash                        26d9328ca8816352bccb879e4a97fd77
Total time                           5354s
```

## Formatting latest databases for other datasets

### Autometa database config

For parameter sweep benchmarking all entrypoints for use with Autometa, the NCBI, GTDB and markers databases are required.

For more information on setting up the necessary autometa databases (NCBI, GTDB & single-copy
markers) see the [Autometa databases documentation](https://autometa.readthedocs.io/en/latest/databases.html "Autometa databases documentation")

- [NCBI](https://autometa.readthedocs.io/en/latest/databases.html#ncbi "Autometa NCBI database documentation")
- [Markers](https://autometa.readthedocs.io/en/latest/databases.html#markers "Autometa markers database documentation")
- [GTDB](https://autometa.readthedocs.io/en/latest/databases.html#genome-taxonomy-database-gtdb "Autometa GTDB database documentation")

### MMseqs2 database config

```bash
REPO="$HOME/metaBenchmarks"
TOOL="mmseqs2"
TOOL_DBDIR="${REPO}/data/databases/${TOOL}"
mkdir -p $TOOL_DBDIR
cd $TOOL_DBDIR
mmseqs databases NR mmseqs2_NR NR_tmp --threads 20
```

### Kraken2 database config

```bash
REPO="$HOME/metaBenchmarks"
TOOL="kraken2"
TOOL_DBDIR="${REPO}/data/databases/${TOOL}"
mkdir -p $TOOL_DBDIR
cd $TOOL_DBDIR
kraken2-build --standard --threads 20 --db kraken2_db
```

#### diamond database config

You may need to download the required NCBI files prior to formatting diamond database if you have not already done so. If you have already downloaded these files and they are in sync with the rest of the tools' formatted databases, you may simply specify the locations of the files.

> NOTE: Constructing the diamond-formatted database with the taxon mapping parameters is required
for taxon-binning benchmarking, i.e. required with the `--outfmt 102` parameter.

e.g. `diamond blastx --outfmt 102 ...`

You may retrieve the respective files from here:

- `--in` Non-redundant (nr) database [ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz](ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz)
- `--taxonmap` file [prot.accession2taxid.gz](ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz)
- Contains `--taxonnodes` and `--taxonnames` files [taxdump.tar.gz](ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz)

> i.e. nodes.dmp, names.dmp, merged.dmp and delnodes.dmp - Found within

```bash
REPO="$HOME/metaBenchmarks"
TOOL="diamond"
TOOL_DBDIR="${REPO}/data/databases/${TOOL}"
mkdir -p $TOOL_DBDIR
cd $TOOL_DBDIR
diamond makedb \
    --in "nr.gz" \
    --db "nr_with_taxonomy" \
    --taxonmap "prot.accession2taxid.gz" \
    --taxonnodes "nodes.dmp" \
    --taxonnames "names.dmp"
```
