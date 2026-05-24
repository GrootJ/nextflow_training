#!/usr/bin/env nextflow

// Module INCLUDE statements
include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'

/*
 * Pipeline parameters
 */
params {
    // Primary input
    input: Path = "data/bam/reads_mother.bam" //"${projectDir}/data/bam/reads_mother.bam"
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

    // Load the file paths for the accessory files (reference and intervals)
    ref_file        = file(params.reference)
    ref_index_file  = file(params.reference_index)
    ref_dict_file   = file(params.reference_dict)
    intervals_file  = file(params.intervals)

    // index BAM
    SAMTOOLS_INDEX(reads_ch)

    // call variants with GATK HaplotypeCaller
     GATK_HAPLOTYPECALLER(
        reads_ch,
        SAMTOOLS_INDEX.out.bam_index,
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    publish:
    bam_index = SAMTOOLS_INDEX.out.bam_index
    vcf = GATK_HAPLOTYPECALLER.out.vcf
    vcf_idx = GATK_HAPLOTYPECALLER.out.idx

}

output {
    bam_index {
        path 'bam'
        mode 'copy'
    }
    vcf {
        path 'vcf'
    }
    vcf_idx {
        path 'vcf'
    }
}
