// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process YARA_MAPPER {
    //echo true
    label 'big'
	//conda '/data/scratch/DMP/UCEC/EVGENMOD/cjames/.conda/envs/nf-core-hlatyping-1.2.0'
	tag "$id"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    input:
    tuple val(id), path(reads)
    path(index)
    val(base_index_name)

    output:
    tuple val(id), path("*.mapped.bam"), emit: bam
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${id}${options.suffix}" : "${id}"
    """
    yara_mapper -e 3 -t ${task.cpus} -f bam ${index}/${base_index_name} ${reads[0]} ${reads[1]} > output.bam
    samtools view -@ ${task.cpus} -hF 4 -f 0x40 -b output.bam > ${prefix}_1.mapped.bam
    samtools view -@ ${task.cpus} -hF 4 -f 0x80 -b output.bam > ${prefix}_2.mapped.bam
    echo \$(yara_mapper --version  2>&1) | grep -e "yara_mapper version:" | sed 's/yara_mapper version: //g' > ${software}.version.txt
    """
    stub:
    """
    echo yara_mapper $options.args -t ${task.cpus} -f bam ${index} ${reads[0]} ${reads[1]} > ${id}.mapped.bam
    touch this.version.txt
    """
}
