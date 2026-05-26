// do not add shebang in module on macbook (unlike in gitpod) #!/usr/bin/env nextflow

/*
 * Call variants with GATK HaplotypeCaller
 */


//the GATK command takes a BAM file (-I), a reference genome (-R), and an intervals file (-L),
// and produces a VCF file (-O) along with its index. The tool also expects the BAM index, reference index,
// and reference dictionary to be co-located with their respective files.

process GATK_HAPLOTYPECALLER {

    container 'community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867'

    input:
    // note: index and dictionary files GATK needs co-located w BAM and reference files - not GATK inputs but nextflow needs to stage them in work-dir
    tuple path (input_bam), path(input_bam_index)
    path ref_fasta
    path ref_index
    path ref_dict
    path interval_list

    output:
    path "${input_bam}.g.vcf", emit: vcf
    path "${input_bam}.g.vcf.idx", emit: idx // not GATK primary output but is output and needs management

    script:
    """
    gatk HaplotypeCaller \
        -R '${ref_fasta}' \
        -I '${input_bam}' \
        -O '${input_bam}.g.vcf' \
        -L '${interval_list}' \
        -ERC GVCF
    """
}
