// do not add shebang #!/usr/bin/env nextflow

/*
 * Generate BAM index file
 */
process SAMTOOLS_INDEX {

    // container community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464
    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    input:
    path bam

    output:
    path "${bam}.bai", emit: bam_index

    script:
    """
    samtools index '${bam}'
    """

}
