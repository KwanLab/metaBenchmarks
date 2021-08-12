#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/benchmark
========================================================================================
    Github : https://github.com/nf-core/benchmark
    Website: https://nf-co.re/benchmark
    Slack  : https://nfcore.slack.com/channels/benchmark
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { BENCHMARK } from './workflows/benchmark'

//
// WORKFLOW: Run main nf-core/benchmark analysis pipeline
//
workflow NFCORE_BENCHMARK {
    BENCHMARK ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_BENCHMARK ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
