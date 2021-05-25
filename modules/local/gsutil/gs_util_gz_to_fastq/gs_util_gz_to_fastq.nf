// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process GS_FILE_TO_FASTQ {
    echo true
    tag "$meta.id"

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    input:
        tuple val(meta), val(reads)
    
    output:
        tuple val(meta), path("*.fastq"), emit: reads

    script:
    """
    gsutil $options.args cat ${reads[0]} | zcat > ${meta.id}_${meta.lane}_R1.fastq
    gsutil $options.args cat ${reads[1]} | zcat > ${meta.id}_${meta.lane}_R2.fastq
    """

    stub:
    """
    # echo ${meta.id} ${reads[0]} ${reads[1]}
    touch ${meta.id}_${meta.lane}_R1.fastq
    touch ${meta.id}_${meta.lane}_R2.fastq
    """
}
