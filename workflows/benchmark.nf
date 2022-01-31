/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.multiqc_config ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/
//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { GET_SOFTWARE_VERSIONS } from '../modules/local/get_software_versions'
include { INPUT_CHECK } from '../subworkflows/local/input_check' addParams( options: [:] )

// Taxon-profilers
include { KRAKEN2 } from '../modules/local/kraken2' addParams( options: [:] )
include { MMSEQS2 } from '../modules/local/mmseqs2' addParams( options: [:] )
include { DIAMOND } from '../modules/local/diamond' addParams( options: [:] )
include { AUTOMETA_V1_MAKE_TAXONOMY_TABLE } from '../modules/local/autometa_v1_make_taxonomy_table.nf' addParams( options: [:] )

// Binners
include { AUTOMETA_V1_BINNING } from '../modules/local/autometa_v1_binning.nf' addParams( options: [:] )
include { MAXBIN2 } from '../modules/local/maxbin2.nf' addParams( options: [:] )
include { METABAT2 } from '../modules/local/metabat2.nf' addParams( options: [:] )
include { MYCC } from '../modules/local/mycc.nf' addParams( options: [:] )

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/
//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC                      } from '../modules/nf-core/modules/fastqc/main'
include { MULTIQC                     } from '../modules/nf-core/modules/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary
def multiqc_report = []

workflow BENCHMARK {

    ch_software_versions = Channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    //
    // Run taxon profiling
    //
    taxon_profiling_ch = INPUT_CHECK.out.taxon_profiling

    KRAKEN2(taxon_profiling_ch)
    MMSEQS2(taxon_profiling_ch)
    AUTOMETA_TAXON_PROFILING_V1(taxon_profiling_ch) 
    AUTOMETA_TAXON_PROFILING_V2(taxon_profiling_ch) 
    DIAMOND(taxon_profiling_ch)

    //
    // Run binning
    //
    binning_ch = INPUT_CHECK.out.binning

    // Binners using cov table
    MYCC(binning_ch)
    MAXBIN2(binning_ch)
    AUTOMETA_V1_BINNING(binning_ch)
    AUTOMETA_V2_BINNING(binning_ch)
    
    // Binners using alignments.bam
    METABAT2(binning_ch)
    VAMB(binning_ch)



    FASTQC (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    //
    // MODULE: Pipeline reporting
    //
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    //
    // MODULE: MultiQC
    //
    workflow_summary    = Workflow{{ short_name[0]|upper }}{{ short_name[1:] }}.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

    MULTIQC (
        ch_multiqc_files.collect()
    )
    multiqc_report = MULTIQC.out.report.toList()
    ch_versions    = ch_versions.mix(MULTIQC.out.versions)
}

/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
========================================================================================
    THE END
========================================================================================
*/
