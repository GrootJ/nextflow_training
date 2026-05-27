#!/usr/bin/env nextflow

// Module INCLUDE statements
include { FASTQC } from './modules/fastqc.nf'
include { TRIM_GALORE } from './modules/trim_galore.nf'
include { HISAT2_ALIGN } from './modules/hisat2_align.nf'

/*
 * Pipeline parameters
 */

// Primary input
params {
    input: Path //= "data/reads/reads_1.fastq.gz" // arrays of paths cannot use typed declarations - but samples sheet should have typed declaration
    hisat2_index_zip: Path // Reference genome archive
    // genome_fasta: Path // Reference genome FASTA file
    // genome_gtf: Path // Reference genome GTF file
}

workflow {

    main:

    // Create input channel from a file path
    reads_ch = channel.fromPath(params.input)

    // Call processes
    // initial QC on raw reads
    FASTQC(reads_ch)

    // Trim adapters and run post-trimming QC
    TRIM_GALORE(reads_ch)

    // Align trimmed reads to reference genome using HISAT2
    HISAT2_ALIGN(
        TRIM_GALORE.out.trimmed_reads,
        file(params.hisat2_index_zip)
        // file(params.genome_fasta),
        // file(params.genome_gtf)
    )

    publish:
    // Declare outputs to publish
    fastqc_html = FASTQC.out.html
    fastqc_zip = FASTQC.out.zip
    trimmed_reads = TRIM_GALORE.out.trimmed_reads
    trimming_reports = TRIM_GALORE.out.trimming_reports
    trimming_fastqc = TRIM_GALORE.out.fastqc_reports
    bam = HISAT2_ALIGN.out.bam
    align_log = HISAT2_ALIGN.out.log

}

output {
    fastqc_html {
        path 'fastqc_html'
    }
    fastqc_zip {
        path 'fastqc_zip'
    }
    trimmed_reads {
        path 'trimming'
    }
    trimming_reports {
        path 'trimming'
    }
    trimming_fastqc {
        path 'trimming'
    }
    bam {
        path 'align'
    }
    align_log {
        path 'align'
    }
}
