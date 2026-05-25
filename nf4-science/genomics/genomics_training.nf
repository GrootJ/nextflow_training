#!/usr/bin/env nextflow

// Module INCLUDE statements
include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'

/*
 * Pipeline parameters
 */
params {
    // Primary input
    input: Path //= "data/bam/reads_mother.bam" // arrays of paths cannot use typed declarations - but samples sheet should have typed declaration
    // Accessory files
    reference: Path
    reference_index: Path
    reference_dict: Path
    intervals: Path
}

workflow {

    main:
    // create a channel for inputs (single file via CLI parameter)
    reads_ch = channel.fromPath(params.input)
            .splitCsv(header: true)
            .map { row -> file(row.reads_bam) }

    // Load the file paths for the accessory files (reference and intervals)
    ref_file        = file(params.reference)
    ref_index_file  = file(params.reference_index)
    ref_dict_file   = file(params.reference_dict)
    intervals_file  = file(params.intervals)

    // index BAM
    SAMTOOLS_INDEX(reads_ch)
    // SAMTOOLS_INDEX.out.view() // see output files (locations)

    // call variants with GATK HaplotypeCaller
     GATK_HAPLOTYPECALLER(
        SAMTOOLS_INDEX.out, // SAMTOOLS_INDEX.out contains the tuple of bam and bam_index
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    publish:
    indexed_bam = SAMTOOLS_INDEX.out
    vcf = GATK_HAPLOTYPECALLER.out.vcf
    vcf_idx = GATK_HAPLOTYPECALLER.out.idx

}

output {
    indexed_bam {
        path 'bam'
    }
    vcf {
        path 'vcf'
    }
    vcf_idx {
        path 'vcf'
    }
}
