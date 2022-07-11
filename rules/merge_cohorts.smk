

COMMON_SNPS = 'data/interim/{cohort_comb}/plink_merged_filtered/prs_{prs_study}/{region}/commonsnps.txt'

rule get_common_snps:
    input:
        expand(SNPS_TO_KEEP_ALL1, cohort = COHORTS, allow_missing = True)
    output:
        COMMON_SNPS
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        cohort_combs = COHORT_COMB[wildcards.cohort_comb]
        shell("Rscript scripts/merge_cohorts/take_intersection.R \
        --input {input} \
        --input-comb {cohort_combs} \
        --output {output}")


# extract the common snps between cohorts

# output
EXTRACTED_PLINK = 'data/interim/{cohort_comb}/plink_merged_filtered/prs_{prs_study}/{region}/{cohort}_final'
EXTRACTED_PLINK_EXT = EXTRACTED_PLINK + '.{ext}'

rule extract_common_snps:
    input:
        snp_list = COMMON_SNPS,
        plink = expand(MERGE_FILTERED1_EXT,ext = EXTENSIONS, allow_missing=True)
    output: 
        expand(EXTRACTED_PLINK_EXT,ext = EXTENSIONS, allow_missing=True)
    params:
        i = MERGE_FILTERED1,
        o = EXTRACTED_PLINK
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i}\
        --extract {input.snp_list}\
        --make-bed --out {params.o}")

def extract_common_snps_output(wildcards):
    return expand(EXTRACTED_PLINK_EXT, # cohort_comb = COHORT_COMB, 
    cohort = COHORT_COMB[wildcards.cohort_comb], 
    ext = EXTENSIONS, # region = REGIONS, 
    allow_missing = True) 

MERGE_LIST_COMBINE = 'data/interim/{cohort_comb}/plink_merged_filtered/prs_{prs_study}/{region}/mergelist.txt'

rule get_merge_list:
    input:
        extract_common_snps_output
    output:
        MERGE_LIST_COMBINE
    threads: 2
    resources:
        mem=8
    run: 
        # remove the first line and suffix
        shell("ls -1v data/interim/{wildcards.cohort_comb}/plink_merged_filtered/prs_{wildcards.prs_study}/{wildcards.region}/*bed | tail -n +2| sed -e's/\.bed$//' >  {output}")


# merge

MERGED_COMBINE_COHORTS = 'data/interim/{cohort_comb}/plink_merged_filtered/prs_{prs_study}/{region}/final'
MERGED_COMBINE_COHORTS_EXT = MERGED_COMBINE_COHORTS + '.{ext}'

rule merge_combined_cohorts:
    input: 
        mlist = MERGE_LIST_COMBINE,
        plink = extract_common_snps_output
    output: expand(MERGED_COMBINE_COHORTS_EXT, ext = EXTENSIONS, allow_missing=True)
    params:
        i = expand(EXTRACTED_PLINK, cohort = 'genome1000',allow_missing=True),
        o = MERGED_COMBINE_COHORTS
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile  {params.i}\
        --merge-list {input.mlist} \
        --make-bed --out {params.o}")

SNP_COUNT_COHORT_COMB = 'data/interim/snp_counts/{prs_study}/{cohort_comb}/{region}/snp_counts.txt'

rule count_snp_cohort_comb:
    input: MERGED_COMBINE_COHORTS + '.bim'
    output: SNP_COUNT_COHORT_COMB
    threads: n_threads_s
    resources: 
        mem=n_mem_s
    shell: 
        '''
        wc -l {input} | awk '{{print $1-1}}' > {output}
        '''



rule merge_cohorts:
    input:
        # expand(MERGE_LIST_COMBINE, cohort_comb = COHORT_COMB.keys(),region = REGIONS)
        expand(MERGED_COMBINE_COHORTS_EXT, cohort_comb=COHORT_COMB.keys(),
        prs_study=PRS_STUDY,
        region=REGIONS,
        ext = EXTENSIONS),
        expand(SNP_COUNT_COHORT_COMB, cohort_comb=COHORT_COMB.keys(),
        prs_study=PRS_STUDY,
        region=REGIONS)




# MERGED_COHORTS = 'data/interim/{cohort_comb}/plink_merged/filtered/{region}/final'
# MERGED_COHORTS_EXT = MERGED_COHORTS + '.{ext}'

# rule merge_cohorts:
#     input: 
#         plink = expand(MERGE_FILTERED1_EXT, cohort = COHORTS,ext = EXTENSIONS, allow_missing = True),
#     output:
#         plink = expand(MERGED_COHORTS_EXT, ext = EXTENSIONS, allow_missing = True)
#     run:
#         cohort_combs = COHORT_COMB[wildcards.cohort_comb]
#         shell("")

