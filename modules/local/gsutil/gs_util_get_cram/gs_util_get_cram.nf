// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process GS_FILE_TO_CRAM {
    label 'process_low'

    tag "$meta.id"

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    input:
        tuple val(meta), val(cram)
    
    output:
        tuple val(meta), path("*.cra{m,i}"), emit: cram

    script:
    """
    gsutil $options.args cp ${cram[0]} ./${meta.id}.cram
    gsutil $options.args cp ${cram[1]} ./${meta.id}.crai
    """

    stub:
    """
    echo "options: $options.args" 
    touch ${meta.id}.cram
    touch ${meta.id}.crai
    """
}
