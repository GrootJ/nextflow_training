// do not add shebang in module on macbook (unlike in gitpod) #!/usr/bin/env nextflow

/*
 * Combine GVCFs into GenomicsDB datastore and run joint genotyping to produce cohort-level calls
 */
process GATK_JOINTGENOTYPING {

    container 'community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867'

    input:
    // note: all_gvcfs and all_gvcfs_indeces are gvcfs and gvcf_indeces collected with .collect
    path all_gvcfs
    path all_gvcfs_indeces
    path interval_list
    path ref_fasta
    path ref_index
    path ref_dict
    val cohort_name

    output:
    path "${cohort_name}_gdb"     , emit: gdb
    path "${cohort_name}.joint.vcf"     , emit: vcf
    path "${cohort_name}.joint.vcf.idx" , emit: idx // not GATK primary output but is output and needs management

    script:

    // dynamically constructed string of all gvcf files with "-V" prefix y
    def gvcfs_line = all_gvcfs.collect { gvcf -> "-V ${gvcf}" }.join(' ')

    """
    gatk GenomicsDBImport \
    ${gvcfs_line} \
    -L ${interval_list} \
    --genomicsdb-workspace-path ${cohort_name}_gdb

    gatk GenotypeGVCFs \
    -R ${ref_fasta} \
    -V gendb://${cohort_name}_gdb \
    -O ${cohort_name}.joint.vcf

    """
}
