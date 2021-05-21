/*
 * functions
 */

include {
    extract_fastq;
    has_extension
} from '../modules/local/functions.nf'
// set up params
tsv_path = null
if ( params.input && ( has_extension( params.input, "tsv" ) ) ) tsv_path = params.input
input_sample = Channel.empty()

if (tsv_path){
    tsv_file = file(tsv_path)
    input_sample = extract_fastq(tsv_file)
} 

base_index_name = params.base_index_name ?  params.base_index_name :  "hla_reference_${params.seqtype}"
modules = params.modules 

include { GS_FILE_TO_FASTQ } from '../modules/local/gsutil/gs_util_gz_to_fastq' addParams(options:modules['gs_util_gz_to_fastq'])
include { CAT_FASTQS }       from '../modules/local/cat/cat'
include { MAKE_OT_CONFIG }   from '../modules/local/local_optitype/configbuilder'
include { YARA_MAPPER }      from '../modules/nf-core/software/yara/mapper/main'
include { OPTITYPE }         from '../modules/nf-core/software/optitype/main'

workflow HLATYPING {
    //convert gs fastq gz to fastq
    //input_sample.view()
    GS_FILE_TO_FASTQ(input_sample)
    // Create config.ini for Optitype
    cat_files = GS_FILE_TO_FASTQ.out
    cat_files = cat_files.map{meta,reads -> [meta["id"],reads]}
    cat_files = cat_files.groupTuple(by:0)
    cat_files = cat_files.map{id,reads -> [id, reads.flatten()]}
    cat_files.view()
    CAT_FASTQS(cat_files)
    MAKE_OT_CONFIG()
    YARA_MAPPER(CAT_FASTQS.out,params.base_index_path,base_index_name)
    OPTITYPE(MAKE_OT_CONFIG.out.ot_config,YARA_MAPPER.out.bam, params.seqtype)
}