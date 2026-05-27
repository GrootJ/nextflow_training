#!/usr/bin/env nextflow   // leave shebang here - was removed in genomics workflow on macOS

/*
 * Run FastQC on input reads
 */
process FASTQC {

    container 'community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18'

    input:
    path reads

    output:
    path "${reads.simpleName}_fastqc.zip", emit: zip // simpleName accessor strips all extensions from filename
    path "${reads.simpleName}_fastqc.html", emit: html

    script:
    """
    fastqc ${reads}
    """

}
