/*
 * STEP 1 - Create config.ini for Optitype
 *
 * Optitype requires a config.ini file with information like
 * which solver to use for the optimization step. Also, the number
 * of threads is specified there for different steps.
 * As we do not want to touch the original source code of Optitype,
 * we simply take information from Nextflow about the available resources
 * and create a small config.ini as first step which is then passed to Optitype.
 */

include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process MAKE_OT_CONFIG {

    publishDir "${params.outdir}/config", mode: params.publish_dir_mode

    output:
    path 'config.ini' , emit : ot_config

    script:
    """
    configbuilder.py --max-cpus ${params.max_cpus} --solver ${params.solver} > config.ini
    """
}