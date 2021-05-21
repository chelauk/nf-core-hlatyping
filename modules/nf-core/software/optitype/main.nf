// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process OPTITYPE {
    tag "$meta.id"
    //conda '/data/scratch/DMP/UCEC/EVGENMOD/cjames/.conda/envs/nf-core-hlatyping-1.2.0'
	label 'big'
	publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }


    input:
    path(config)
    tuple val(meta), path(bam)
    val(seqtype)

    output:
    tuple val(meta), path("${prefix}"), emit: output
    path "*.version.txt"              , emit: version

    script:
    def software = getSoftwareName(task.process)
    prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    # Run the actual OptiType typing with options.args
    OptiTypePipeline.py -i ${bam} -c ${config} --${seqtype} $options.args --prefix $prefix --outdir $prefix

    #Couldn't find a nicer way of doing this
    cat \$(which OptiTypePipeline.py) | grep -e "Version:" | sed -e "s/Version: //g" > ${software}.version.txt
    """

    stub:
	prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    echo ${bam} ${config} ${meta.seq_type} $options.args --prefix $prefix --outdir $prefix
    touch test.version.txt
	mkdir ${prefix}
	"""
}
