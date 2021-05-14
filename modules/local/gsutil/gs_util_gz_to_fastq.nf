// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process GS_FILE_TO_FASTQ {
    echo true
    tag "$meta.id"
    label 'process_medium'

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    input:
        tuple val(meta), val(file1), val(file2)
    
    output:
        tuple val(meta), path("*.fastq"), emit: reads

    script:
    """
    gsutil $options.args cat $file1 | zcat > ${meta.id}_R1.fastq
    gsutil $options.args cat $file2 | zcat > ${meta.id}_R2.fastq
    """

    stub:
    """
    echo $options.args
    echo ${meta.id}_R1.fastq ${meta.id}_R2.fastq 
    touch ${meta.id}_R1.fastq
    touch ${meta.id}_R2.fastq
    """
}