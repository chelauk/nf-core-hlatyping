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
/* --              SETUP PARAMS                -- */
////////////////////////////////////////////////////

base_index_name = params.base_index_name ? params.base_index_name : "hla_reference_${params.seqtype}"
base_index_path = params.base_index_path ? params.base_index_path : null
modules = params.modules 

// Initialize each params in params.genomes, catch the command line first if it was defined
params.fasta                   = params.genome ? params.genomes[params.genome].fasta       ?: false : false
file("${params.outdir}/no_file").text = "no_file\n"

// Initialize file channels based on params, defined in the params.genomes[params.genome] scope

fasta             = params.fasta             ? file(params.fasta)             : file("${params.outdir}/no_file")

// Import functions
include {
    extract_fastq;
    extract_cram;
    has_extension
} from 'modules/local/functions.nf'
// set up params
tsv_path = null
if ( params.input && ( has_extension( params.input, "tsv" ) ) ) tsv_path = params.input
input_sample = Channel.empty()

if (tsv_path && ( params.type == 'fastq' )){
    tsv_file = file(tsv_path)
    input_sample = extract_fastq(tsv_file)
}
else if (tsv_path && ( params.type == 'cram' )){
    tsv_file = file(tsv_path)
    input_sample = extract_cram(tsv_file)
}

////////////////////////////////////////////////////
/* --         PRINT PARAMETER SUMMARY          -- */
////////////////////////////////////////////////////

def summary_params = NfcoreSchema.params_summary_map(workflow, params, json_schema)
log.info NfcoreSchema.params_summary_log(workflow, params, json_schema)




include { HLATYPING } from './workflows/hlatyping' addParams ( 
    gs_util_get_cram_options:                                           modules['gs_get_cram'],
    gs_util_gz_to_fastq_options:                                        modules['gs_util_gz_to_fastq'])

workflow {
    HLATYPING( base_index_name,base_index_path,fasta)
}