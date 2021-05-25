// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process OPTITYPE {
    tag "$id"
    //conda '/data/scratch/DMP/UCEC/EVGENMOD/cjames/.conda/envs/nf-core-hlatyping-1.2.0'
	label 'process_high'
	publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process)) }


    input:
    path(config)
    tuple val(id), path(bam)
    val(seqtype)

    output:
    tuple val(id), path("${prefix}"), emit: output
    path "*.version.txt"              , emit: version

    script:
    def software = getSoftwareName(task.process)
    prefix   = options.suffix ? "${id}${options.suffix}" : "${id}"
    """
    # Run the actual OptiType typing with options.args
    OptiTypePipeline.py -i ${bam} -c ${config} --${seqtype} $options.args --prefix $prefix --outdir $prefix

    #Couldn't find a nicer way of doing this
    cat \$(which OptiTypePipeline.py) | grep -e "Version:" | sed -e "s/Version: //g" > ${software}.version.txt
    """

    stub:
	prefix   = options.suffix ? "${id}${options.suffix}" : "${id}"
    """
    echo ${bam} ${config} ${seqtype} $options.args --prefix $prefix --outdir $prefix
    touch test.version.txt
	mkdir ${prefix}
	"""
}
