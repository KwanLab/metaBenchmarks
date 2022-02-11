//
// Check input samplesheet and get read channels
//


include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check' 

workflow INPUT_CHECK {
    take:
        samplesheet // file: /path/to/samplesheet.csv

    main:
        SAMPLESHEET_CHECK ( samplesheet )
        
        // Create a reads channel
        SAMPLESHEET_CHECK.out.splitCsv ( header:true, sep:',' )
            .map { create_fastq_channels(it) }
            .set { reads }
        
        // Create a taxon-profiling channel
        SAMPLESHEET_CHECK.out.splitCsv ( header:true, sep:',' )
            .map { create_taxon_profiling_channels(it) }
            .set { taxon_profiling }
        
        // Create a binning channel
        SAMPLESHEET_CHECK.out.splitCsv ( header:true, sep:',' )
            .map { create_binning_channels(it) }
            .set { binning }

    emit:
        reads // channel: [ val(meta), [ reads ] ]
        taxon_profiling // channel: [val(meta), [ assembly ]]
        binning // channel: [val(meta), [ assembly, coverage, alignments ]]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.sample
    def array = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (!file(row.fastq_2).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
    }
    array = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
    return array
}

// Function to get list of [ meta, [ assembly ] ]
def create_taxon_profiling_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.sample
    def array = []
    if (!file(row.assembly).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> assembly file does not exist!\n${row.assembly}"
    }
    array = [ meta, [ file(row.assembly) ] ]
    return array
}

// Function to get list of [ meta, [ fastq_1, fastq_2, assembly ] ]
def create_binning_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.sample
    def array = []
    if (!file(row.assembly).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> assembly file does not exist!\n${row.assembly}"
    }
    if (!file(row.coverage_tab).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> coverage_tab file does not exist!\n${row.coverage_tab}"
    }
    if (!file(row.alignments).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> alignments file does not exist!\n${row.alignments}"
    }
    array = [ meta, [ file(row.assembly), file(row.coverage_tab), file(row.alignments) ] ]
    return array
}
