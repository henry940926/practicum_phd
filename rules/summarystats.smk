# GWASSUMMARY_HGI = 'data/raw/hgi_hospvsnon/summarystats/COVID19_HGI_B1_ALL_leave_UKBB_23andme_20210107.txt'
# FILTERED_SNP_HGI = 'data/raw/hgi_hospvsnon/summarystats/snp_filter.txt'
# FILTERED_SUMMARY_HGI = 'data/raw/hgi_hospvsnon/summarystats/summary_stats.txt'
# FILTERED_RANGE_HGI = 'data/raw/hgi_hospvsnon/summarystats/ranges.txt'

# filter the SNPS based on different summary stats

GWASSUMMARY = 'data/raw/{prs_study}/summarystats/summary_hg38.txt'
FILTERED_SNP = 'data/raw/{prs_study}/summarystats/snp_filter.txt'
FILTERED_SUMMARY = 'data/raw/{prs_study}/summarystats/summary_stats.txt'
FILTERED_RANGE = 'data/raw/{prs_study}/summarystats/ranges.txt'


rule filtersnps:
    input: GWASSUMMARY
    output: 
        snp = FILTERED_SNP,
        summary = FILTERED_SUMMARY,
        ranges = FILTERED_RANGE
    threads: n_threads_s
    resources: 
        mem=n_mem_s
    shell: 'Rscript scripts/hgi/filtersnps.R \
    --input {input} \
    --output-s {output.summary} \
    --output-f {output.snp} \
    --output-r {output.ranges}'


rule summary_stats:
    input:
        expand(FILTERED_SNP, prs_study = PRS_STUDY)