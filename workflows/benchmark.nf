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
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { PREPARE_COVERAGE_INPUT_FORMATS as PREP_COV_INPUTS } from '../subworkflows/local/prepare_coverage_input_formats'

// Taxon-profilers
include { CHECK_KRAKEN_DB; DOWNLOAD_KRAKEN } from '../modules/local/download_kraken2'
include { KRAKEN2 } from '../modules/local/kraken2'
include { MMSEQS2 } from '../subworkflows/local/mmseqs2'
//include { DIAMOND } from '../subworkflows/local/diamond'
include { AUTOMETA_V1_MAKE_TAXONOMY_TABLE as AUTOMETA_TAXON_PROFILING_V1 } from '../modules/local/autometa_v1_make_taxonomy_table.nf'

// Binners
include { AUTOMETA_V1_BINNING } from '../modules/local/autometa_v1_binning.nf'
include { MAXBIN2 } from '../modules/local/maxbin2.nf' 
include { METABAT2 } from '../modules/local/metabat2.nf'
include { MYCC } from '../modules/local/mycc.nf' 

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

    // Get paths to taxon-profiling databases
    // file("/media/bigdrive1/Databases/kraken2/kraken2_db")
    kraken2_db = file(params.kraken2_db)
    ncbi_db = file(params.ncbi_db)
    
    //
    // Run taxon profiling
    //
    taxon_profiling_ch = INPUT_CHECK.out.taxon_profiling
    KRAKEN2(taxon_profiling_ch, kraken2_db)
    MMSEQS2(taxon_profiling_ch, mmseqs2_db)
    AUTOMETA_TAXON_PROFILING_V1(taxon_profiling_ch, ncbi_db)
    AUTOMETA_TAXON_PROFILING_V2(taxon_profiling_ch, ncbi_db)
    DIAMOND(taxon_profiling_ch, ncbi_db)

    //
    // Run binning
    //
    PREP_COV_INPUTS(
        INPUT_CHECK.out.binning
    )
    
    binning_tab_ch = PREP_COV_INPUTS.out.table
    binning_bam_ch = PREP_COV_INPUTS.out.bam

    // Binners using cov table
    MYCC(binning_tab_ch)
    MAXBIN2(binning_tab_ch)
    AUTOMETA_V1_BINNING(binning_tab_ch)
    AUTOMETA_V2_BINNING(binning_tab_ch)
    
    // Binners using alignments.bam
    binning_ch
        .join(PREP_COV_INPUTS.out.depth)
        .set{metabat2_ch}
    METABAT2(metabat2_ch)
    VAMB(binning_bam_ch)



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
