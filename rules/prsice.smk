
# output
PRSICE_RESULT = 'data/result/{cohort_misc_relate}/PRSice/{prs_study}/{region}/result'

PRSICE_RESULT_EXT = PRSICE_RESULT + '.{prsiceext}'

PRSICE_EXT = ['best','prsice','summary','all_score']

# inputs

PRSICE_TARGET = 'data/interim/{cohort_misc_relate}/plink_merged_filtered/prs_{prs_study}/{region}/final'
# UPDATED_SUMMARIES = 'data/interim/{cohort_misc_relate}/plink_merged_filtered/prs_{prs_study}/{region}/updated_summary.txt'

rule prsice_calc:
    input: 
        summary_stats = FILTERED_SUMMARY,
        cov = COV_PHE
    output: expand(PRSICE_RESULT_EXT,prsiceext=PRSICE_EXT,allow_missing=True)
    threads: n_threads
    resources:
        mem=n_mem
    params:
        target = PRSICE_TARGET,
        out = PRSICE_RESULT,
        kb = 500
    run:
        shell("Rscript scripts/PRSice/PRSice.R \
        --prsice scripts/PRSice/PRSice_linux \
        --base {input.summary_stats} \
        --target {params.target} \
        --thread {threads} \
        --binary-target T \
        --clump-kb {params.kb} \
        --stat all_inv_var_meta_beta \
        --chr 1 \
        --bp POS \
        --A1 ALT \
        --A2 REF \
        --pvalue all_inv_var_meta_p \
        --snp SNP \
        --pheno {input.cov} \
        --pheno-col casecontrol \
        --cov {input.cov} \
        --cov-col @V[1-4]\
        --beta \
        --all-score \
        --quantile 10 \
        --score std \
        --out {params.out}")

rule prsice:
    input:
        expand(PRSICE_RESULT_EXT, cohort_misc_relate = COHORT_SUB2,
        prs_study = PRS_STUDY, region = REGIONS,
        prsiceext = PRSICE_EXT)