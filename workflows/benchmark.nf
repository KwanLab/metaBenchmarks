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
include { CHECK_KRAKEN_DB; DOWNLOAD_KRAKEN } from '../modules/local/kraken2/download_kraken2'
include { KRAKEN2 } from '../modules/local/kraken2/kraken2'
include { MMSEQS2 } from '../subworkflows/local/mmseqs2'
//include { DIAMOND } from '../subworkflows/local/diamond'
include { AUTOMETA_V1_MAKE_TAXONOMY_TABLE as AUTOMETA_V1_TAXON_PROFILING } from '../modules/local/autometa_v1/make_taxonomy_table.nf'

// Binners
include { AUTOMETA_V1_BINNING } from '../modules/local/autometa_v1/binning.nf'
include { AUTOMETA_V2_BINNING } from '../modules/local/autometa_v2/binning.nf'
include { AUTOMETA_BENCHMARK_BINNING as BENCHMARK_BINNING} from '../modules/local/autometa_v2/benchmark_binning.nf'
include { AUTOMETA_BENCHMARK_TAXON_PROFILING as BENCHMARK_TAXON_PROFILING } from '../modules/local/autometa_v2/benchmark_taxon_profiling.nf'
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

    // Get paths to taxon-profiling databases
    ncbi_db = file(params.ncbi_db)
    
    //
    // Run taxon profiling
    //
    taxon_profiling_ch = INPUT_CHECK.out.taxon_profiling
    // file("/media/bigdrive1/Databases/kraken2/kraken2_db")
    

    if (params.kraken2_download_permission) {
        DOWNLOAD_KRAKEN(params.kraken2_db)
    }
    
    CHECK_KRAKEN_DB(params.kraken2_db)

    // TODO: Fix/create database input channels
    
    KRAKEN2(taxon_profiling_ch, params.kraken2_db)
    MMSEQS2(taxon_profiling_ch, mmseqs2_db)
    AUTOMETA_V1_TAXON_PROFILING(taxon_profiling_ch, ncbi_db)
    AUTOMETA_V2_TAXON_PROFILING(taxon_profiling_ch, ncbi_db)
    //DIAMOND(taxon_profiling_ch, ncbi_db)

    // TODO: Create channel corresponding to taxon-profiling results and appropriate
    // reference ground-truths file
    KRAKEN2.out.taxon_profiling
        .combine(MMSEQS2.out.taxon_profiling)
        .combine(AUTOMETA_V1_TAXON_PROFILING.out.taxon_profiling)
        .combine(AUTOMETA_V2_TAXON_PROFILING.out.taxon_profiling)
        .set{taxon_profiling_results_ch}
    
    // Benchmark taxon-profiling results
    BENCHMARK_TAXON_PROFILING(
        taxon_profiling_results_ch,
        ncbi_db
    )

    //
    // Run binning
    //
    PREP_COV_INPUTS(
        INPUT_CHECK.out.binning
    )
    
    // Binners using cov table
    PREP_COV_INPUTS.out.table
        .set{binning_tab_ch}

    MYCC(binning_tab_ch)
    MAXBIN2(binning_tab_ch)
    AUTOMETA_V1_BINNING(binning_tab_ch)
    AUTOMETA_V2_BINNING(binning_tab_ch)
    
    // Binners using alignments.bam
    PREP_COV_INPUTS.out.bam
        .set{binning_bam_ch}

    VAMB(binning_bam_ch)

    // Binners using coverage depth table
    binning_ch
        .join(PREP_COV_INPUTS.out.depth)
        .set{metabat2_ch}
    
    METABAT2(metabat2_ch)

    // TODO: Create channel corresponding to binning results and appropriate
    // reference ground-truths file
    MYCC.out.binning
        .combine(VAMB.out.binning)
        .combine(MAXBIN2.out.binning)
        .combine(AUTOMETA_V1_BINNING.out.binning)
        .combine(AUTOMETA_V2_BINNING.out.binning)
        .set{binning_classification_results_ch}

    BENCHMARK_BINNING(binning_classification_results_ch)

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
