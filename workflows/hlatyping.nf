/*
 * functions
 */

include {
    extract_fastq;
    extract_cram;
    has_extension
} from '../modules/local/functions.nf'
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

base_index_name = params.base_index_name ?  params.base_index_name :  "hla_reference_${params.seqtype}"
modules = params.modules 


include { CRAM_WF }          from '../subworkflows/cram_wf'                                   addParams(
    gs_util_get_cram_options:                                                                 modules['gs_get_cram'])
include { FASTQ_WF }         from '../subworkflows/fastq_wf'                                  addParams(
    gs_util_gz_to_fastq_options:                                                              modules['gs_util_gz_to_fastq'])

include { MAKE_OT_CONFIG }   from '../modules/local/local_optitype/configbuilder'
include { YARA_MAPPER }      from '../modules/nf-core/software/yara/mapper/main'
include { OPTITYPE }         from '../modules/nf-core/software/optitype/main'

workflow HLATYPING {
    if ( params.type == 'fastq' ) {
        FASTQ_WF(input_sample)
    }

    if ( params.type == 'cram' ) {
        CRAM_WF(input_sample)
    }

    if (params.type == 'fastq'){
        merged_reads = FASTQ_WF.out.merged_reads
    }

    else if ( params.type = 'cram') {
        //input_sample.view()
        merged_reads = CRAM_WF.out.merged_reads
    }

    MAKE_OT_CONFIG()
    YARA_MAPPER(merged_reads,params.base_index_path,base_index_name)
    OPTITYPE(MAKE_OT_CONFIG.out.ot_config,YARA_MAPPER.out.bam, params.seqtype)
}