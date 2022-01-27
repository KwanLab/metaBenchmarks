
process GET_GENOMES_FOR_MOCK {
    def genome_count = options.args2.tokenize('|').size()
    tag "fetching ${genome_count} genomes"

    storeDir = 'mock_data/genomes'
    cache 'lenient'

    conda (params.enable_conda ? "bioconda::emboss=6.6.0" : null)
    container "jasonkwan/autometa-nf-modules-get_genomes_for_mock"

    output:
        path "metagenome.fna.gz", emit: metagenome
        path "combined_nucleotide.fna.gz", emit: combined_nucleotide
        path "fake_spades.fna.gz", emit: fake_spades_coverage
        path "assembly_to_locus.txt", emit: assembly_to_locus
        path "assemblies.txt", emit: assemblies
        path "assembly_report.txt", emit: assembly_report

    """
    curl -s ${options.args} > assembly_report.txt

    grep -E "${options.args2}" assembly_report.txt |\\
        awk -F '\\t' '{print \$20}' |\\
        sed 's,https://,rsync://,' |\\
            xargs -n 1 -I {} \
                rsync -am \
                    --exclude='*_rna_from_genomic.fna.gz' \
                    --exclude='*_cds_from_genomic.fna.gz' \
                    --include="*_genomic.fna.gz" \
                    --include="*_protein.faa.gz" \
                    --include='*/' \
                    --exclude='*' {} .

    # "clean_mock_data.sh" is here: ~/Autometa/bin/clean_mock_data.sh
    clean_mock_data.sh
    """
}


process SAMTOOLS_WGSIM {
    // This process is used to create simulated reads from an input FASTA file
    label 'process_low'

    conda (params.enable_conda ? "bioconda::samtools=1.13" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/samtools:1.12--hd5e65b6_0"
    } else {
        container "quay.io/biocontainers/samtools:1.12--hd5e65b6_0"
    }

    input:
    path fasta

    output:
    path("reads_1.fastq"), emit: fastq_1
    path("reads_2.fastq"), emit: fastq_2
    path "*.version.txt" , emit: version

    """
    # https://sarahpenir.github.io/bioinformatics/Simulating-Sequence-Reads-with-wgsim/
    wgsim -1 300 -2 300 -r 0 -R 0 -X 0 -e 0 ${fasta} reads_1.fastq reads_2.fastq

    echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' > samtools.version.txt
    """
}

workflow CREATE_MOCK {

    main:
        // Download and format fasta files from specfied whole genome assemblies (genomes set from "get_genomes_for_mock" parameter in ~Autometa/conf/modules.config)
        GET_GENOMES_FOR_MOCK()

        // Create fake reads from input genome sequences
        SAMTOOLS_WGSIM(GET_GENOMES_FOR_MOCK.out.metagenome)

        // Format everything with a meta map for use in the main Autometa pipeline
        GET_GENOMES_FOR_MOCK.out.fake_spades_coverage
        .map { row ->
                    def meta = [:]
                    meta.id = "mock_data"
                    return [ meta, row ]
            }
        .set { ch_fasta }
        GET_GENOMES_FOR_MOCK.out.assembly_to_locus
        .map { row ->
                    def meta = [:]
                    meta.id = "mock_data"
                    return [ meta, row ]
            }
        .set { assembly_to_locus }
        GET_GENOMES_FOR_MOCK.out.assembly_report
        .map { row ->
                    def meta = [:]
                    meta.id = "mock_data"
                    return [ meta, row ]
            }
        .set { assembly_report }

    emit:
        assembly = ch_fasta
        reads_1 = SAMTOOLS_WGSIM.out.fastq_1
        reads_2 = SAMTOOLS_WGSIM.out.fastq_2
        assembly_to_locus = assembly_to_locus
        assembly_report = assembly_report
}

