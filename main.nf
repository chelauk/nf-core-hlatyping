#!/usr/bin/env nextflow
/*
========================================================================================
                         nf-core/hlatyping
========================================================================================
*/

nextflow.enable.dsl=2

log.info Headers.nf_core(workflow, params.monochrome_logs)

////////////////////////////////////////////////////
/* --               PRINT HELP                 -- */
////////////////////////////////////////////////////

def json_schema = "$projectDir/nextflow_schema.json"
if (params.help) {
    def command = "nextflow run nf-core/hlatyping --input 'input.tsv' -profile docker"
    log.info NfcoreSchema.params_help(workflow, params, json_schema, command)
    exit 0
}

////////////////////////////////////////////////////
/* --         PRINT PARAMETER SUMMARY          -- */
////////////////////////////////////////////////////

def summary_params = NfcoreSchema.params_summary_map(workflow, params, json_schema)
log.info NfcoreSchema.params_summary_log(workflow, params, json_schema)

workflow {
    include { HLATYPING } from './workflows/hlatyping' addParams ( summary_params: summary_params )
    HLATYPING()
}