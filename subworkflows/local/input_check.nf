//
// Check input samplesheet and get read channels
//

params.options = [:]

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check' addParams( options: params.options )

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
    
    SAMPLESHEET_CHECK.out.splitCsv ( header:true, sep:',' )
        .map { create_fastq_channels(it) }
        .set { reads }
    
    SAMPLESHEET_CHECK.out.splitCsv ( header:true, sep:',' )
        .map { create_taxon_profiling_channels(it) }
        .set { taxon_profiling }
    
    SAMPLESHEET_CHECK.out.splitCsv ( header:true, sep:',' )
        .map { create_binning_channels(it) }
        .set { binning }

    emit:
    reads // channel: [ val(meta), [ reads ] ]
    taxon_profiling // channel: [val(meta), [ fwd_reads, rev_reads, assembly ]]
    binning // channel: [val(meta), [ fwd_reads, rev_reads, assembly ]]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.sample
    meta.single_end   = row.single_end.toBoolean()

    def array = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        array = [ meta, [ file(row.fastq_1) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        array = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
    }
    return array
}

// Function to get list of [ meta, [ fastq_1, fastq_2, assembly ] ]
def create_taxon_profiling_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.sample
    meta.single_end   = row.single_end.toBoolean()

    def array = []
    if (!file(row.assembly).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> assembly file does not exist!\n${row.assembly}"
    }
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        array = [ meta, [ file(row.fastq_1), file(row.assembly) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        array = [ meta, [ file(row.fastq_1), file(row.fastq_2), file(row.assembly) ] ]
    }
    return array
}

// Function to get list of [ meta, [ fastq_1, fastq_2, assembly ] ]
def create_binning_channels(LinkedHashMap row) {
    def meta = [:]
    meta.id           = row.sample
    meta.single_end   = row.single_end.toBoolean()

    def array = []
    if (!file(row.assembly).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> assembly file does not exist!\n${row.assembly}"
    }
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        array = [ meta, [ file(row.fastq_1), file(row.assembly) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        array = [ meta, [ file(row.fastq_1), file(row.fastq_2), file(row.assembly) ] ]
    }
    return array
}
