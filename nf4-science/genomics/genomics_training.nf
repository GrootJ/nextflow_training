#!/usr/bin/env nextflow

// Module INCLUDE statements
include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'
include { GATK_JOINTGENOTYPING } from './modules/gatk_jointgenotyping.nf'

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
    // Base name for final output file
    cohort_name: String
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
        SAMTOOLS_INDEX.out, // SAMTOOLS_INDEX.out contains the tuple of bam and bam_index for each bam
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    // Collect variant calling outputs across samples
    all_gvcfs_ch = GATK_HAPLOTYPECALLER.out.vcf.collect()
    all_idxs_ch = GATK_HAPLOTYPECALLER.out.idx.collect()

       // call variants with GATK HaplotypeCaller
     GATK_JOINTGENOTYPING(
        all_gvcfs_ch,
        all_idxs_ch,
        intervals_file,
        ref_file,
        ref_index_file,
        ref_dict_file,
        params.cohort_name
    )

    publish:
    indexed_bam = SAMTOOLS_INDEX.out
    gvcf = GATK_HAPLOTYPECALLER.out.vcf
    gvcf_idx = GATK_HAPLOTYPECALLER.out.idx
    //gdb = GATK_JOINTGENOTYPING.out.gdb
    joint_vcf = GATK_JOINTGENOTYPING.out.vcf
    joint_vcf_idx = GATK_JOINTGENOTYPING.out.idx

}

output {
    indexed_bam {
        path 'bam'
    }
    gvcf {
        path 'gvcf'
    }
    gvcf_idx {
        path 'gvcf'
    }
/*     gdb {
        path 'gdb'
    } */
    joint_vcf {
        path '.'
    }
    joint_vcf_idx {
        path '.'
    }

}
