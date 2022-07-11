"""
Merge files for PCA

"""


COMMON_SNPS_PCA = 'data/interim/{cohort_comb}/pca/common_snps.txt'
rule get_common_snps_pca:
    input:
        expand(PCAFINAL_EXT, cohort = COHORTS, ext = 'bim')
    output:
        COMMON_SNPS_PCA
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        cohort_combs = COHORT_COMB[wildcards.cohort_comb]
        shell("Rscript scripts/merge_cohorts/take_intersection.R \
        --input {input} \
        --input-comb {cohort_combs} \
        --output {output}")


## extract the common snps between cohorts

# extract the common snps between cohorts

# output
EXTRACTED_PLINK_PCA = 'data/interim/{cohort_comb}/pca/{cohort}_final'
EXTRACTED_PLINK_PCA_EXT = EXTRACTED_PLINK_PCA + '.{ext}'

rule extract_common_snps_pca:
    input:
        snp_list = COMMON_SNPS_PCA,
        plink = expand(PCAFINAL_EXT,ext = EXTENSIONS, allow_missing=True)
    output: 
        expand(EXTRACTED_PLINK_PCA_EXT,ext = EXTENSIONS, allow_missing=True)
    params:
        i = PCAFINAL,
        o = EXTRACTED_PLINK_PCA
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i}\
        --extract {input.snp_list}\
        --make-bed --out {params.o}")


MERGE_LIST_COMBINE_PCA = 'data/interim/{cohort_comb}/pca/mergelist.txt'


def get_merge_list_pca_input(wildcards):
    return expand(EXTRACTED_PLINK_PCA_EXT, 
    cohort = COHORT_COMB[wildcards.cohort_comb], 
    ext = EXTENSIONS, 
    allow_missing = True) 

rule get_merge_list_pca:
    input:
        get_merge_list_pca_input
    output:
        MERGE_LIST_COMBINE_PCA
    threads: 2
    resources:
        mem=8
    run: 
        shell("mkdir -p data/interim/{wildcards.cohort_comb}/pca/")
        # remove the first line and suffix
        shell("ls -1v data/interim/{wildcards.cohort_comb}/pca/*.bed | tail -n +2| sed -e's/\.bed$//' >  {output}")


# # merge

MERGED_COMBINE_COHORTS_PCA = 'data/interim/{cohort_comb}/plink_popstra/pca/merged1_22'
MERGED_COMBINE_COHORTS_PCA_EXT = MERGED_COMBINE_COHORTS_PCA + '.{ext}'

rule merge_combined_cohorts_pca:
    input: 
        mlist = MERGE_LIST_COMBINE_PCA,
        plink = get_merge_list_pca_input
    output: expand(MERGED_COMBINE_COHORTS_PCA_EXT, ext = EXTENSIONS, allow_missing=True)
    params:
        i = expand(EXTRACTED_PLINK_PCA, cohort = 'genome1000', allow_missing=True),
        o = MERGED_COMBINE_COHORTS_PCA
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile  {params.i}\
        --merge-list {input.mlist} \
        --make-bed --out {params.o}")

PCA_SNP_COUNT_COHORT_COMB = 'data/interim/snp_counts/pca/{cohort_comb}/pca_snp_counts.txt'

rule count_pca_snp_cohort_comb:
    input: MERGED_COMBINE_COHORTS_PCA + '.bim'
    output: PCA_SNP_COUNT_COHORT_COMB
    threads: n_threads_s
    resources: 
        mem=n_mem_s
    shell: 
        '''
        wc -l {input} | awk '{{print $1-1}}' > {output}
        '''

rule merge_cohorts_pca:
    input:
        expand(MERGED_COMBINE_COHORTS_PCA_EXT, 
        ext = EXTENSIONS,
        cohort_comb=COHORT_COMB.keys()),
        expand(PCA_SNP_COUNT_COHORT_COMB, 
        cohort_comb=COHORT_COMB.keys())




