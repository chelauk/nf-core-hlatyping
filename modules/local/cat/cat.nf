// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process CAT_FASTQS {
    //echo true
    tag "$id"

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:id) }

    input:
        tuple val(id), path(reads)
    
    output:
        tuple val(id), path("*merged_R{1,2}.fastq"), emit: reads

    script:
    """
    cat ${read1.sort().join(' ')} > ${id}_merged_R1.fastq
    cat ${read2.sort().join(' ')} > ${id}_merged_R2.fastq
    """

    stub:
    def reads_list = reads.collect{ it.toString() }
    def read1 = []
    def read2 = []
    reads_list.eachWithIndex{ v, ix -> ( ix & 1 ? read2 : read1 ) << v }
    """
    echo cat ${read1.sort().join(' ')} 
    echo cat ${read2.sort().join(' ')}
    touch ${id}_merged_R1.fastq
    touch ${id}_merged_R2.fastq
    """
}
