// do not add shebang in module on macbook (unlike in gitpod) #!/usr/bin/env nextflow

/*
 * Generate BAM index file
 */
process SAMTOOLS_INDEX {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'  //  this is linux amd64 container
    // linux arm64 container matches apple silicon but amd64 works better w gatk // container 'community.wave.seqera.io/library/samtools:1.20--35c62f73ca81c7f7'

    input:
    path bam

    output:
    tuple path(bam), path("${bam}.bai")
    // path "${bam}.bai", emit: bam_index

    script:
    """
    samtools index '${bam}'
    """

}
