// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process CRAM_TO_FASTQ {
    cpus 6
    
    tag "${meta.id}"

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:id) }

    input:
        tuple val(meta), path(cram)

    output:
        tuple val(meta), path("*merged_R{1,2}.fastq"), emit: reads

    script:
    """
    samtools fastq -@ ${task.cpus} -1 ${meta.id}_merged_R1.fastq -2 ${meta.id}_merged_R2.fastq -0 /dev/null -s /dev/null ${meta.id}.cram
    """

    stub:
    """
    touch ${meta.id}_merged_R1.fastq
    touch ${meta.id}_merged_R2.fastq
    """
}
