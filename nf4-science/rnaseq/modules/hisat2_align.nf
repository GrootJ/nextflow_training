#!/usr/bin/env nextflow

/*
 * Align reads to a reference genome
 */
process HISAT2_ALIGN {

    container 'community.wave.seqera.io/library/hisat2_samtools:5e49f68a37dc010e'

    input:
    path reads
    path genome_index
    // path genome_fasta
    // path genome_gtf

    output:
    path "${reads.simpleName}.bam", emit: bam
    path "${reads.simpleName}.hisat2.log", emit: log


    script:
    """
    tar -xzvf ${genome_index}
    hisat2 -x ${genome_index.simpleName} \
        -U ${reads} \
        --new-summary \
        --summary-file ${reads.simpleName}.hisat2.log | samtools view -bS -o ${reads.simpleName}.bam
    """
}
