// Module INCLUDE statements
include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'

/*
 * Pipeline parameters
 */
params {
    // Primary input
    input: Path = "../data/bam/reads_mother.bam" //"${projectDir}/data/bam/reads_mother.bam"
}

workflow {

    main:
    // create a channel for inputs (single file via CLI parameter)
    reads_ch = channel.fromPath(params.input)

    // index BAM
    SAMTOOLS_INDEX(reads_ch)

    publish:
    bam_index = SAMTOOLS_INDEX.out.bam_index
}

output {
    bam_index {
        path 'bam'
        mode 'copy'
    }
}
