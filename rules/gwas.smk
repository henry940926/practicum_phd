"""
GWAS related

"""



PLINK_ORI_MAF = 'data/interim/{cohort_misc_relate}/plink_maf_all/maf_{maf}/all'
PLINK_ORI_MAF_EXT = PLINK_ORI_MAF + '.{ext}'

## inputs
PLINK_ORIGINAL = 'data/interim/{cohort_misc_relate}/plink/all'
PLINK_ORIGINAL_EXT = PLINK_ORIGINAL + '.{ext}'

# MAF filter applied to raw data

rule maf_all_raw:
    input: 
        plink = expand(PLINK_ORIGINAL_EXT, ext = EXTENSIONS, allow_missing = True)
    output: expand(PLINK_ORI_MAF_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        i = PLINK_ORIGINAL,
        o = PLINK_ORI_MAF
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --maf {wildcards.maf} \
        --make-bed \
        --out {params.o}")

# Get covariates and outcome
COV_PHE = 'data/result/{cohort_misc_relate}/covariates.txt'
COV_PHE0 = 'data/result/{cohort_misc_relate}/covariates_0fid.txt'
COV_NO_PHE = 'data/result/{cohort_misc_relate}/pca/kd_clive/all/prs_clin_pc_reg.csv'
rule get_pheo_cov:
    input:  COV_NO_PHE
    output: 
        c1 = COV_PHE,
        c0 = COV_PHE0
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/gwas/get_cov_phe.R \
        --input {input} \
        --output {output.c1} \
        --output-nofid {output.c0}")

ASSOC_RESULTS = 'data/result/{cohort_misc_relate}/gwas/outcome'
ASSOC_RESULTS_EXT = ASSOC_RESULTS + '.assoc.logistic'
rule associ:
    input: 
        plink = expand(PLINK_ORI_MAF_EXT, ext = EXTENSIONS, 
        maf = MAF, allow_missing = True),
        phe = COV_PHE0
    output:
        ASSOC_RESULTS_EXT
    threads: n_threads
    resources:
        mem=n_mem
    params:
        i = expand(PLINK_ORI_MAF, maf = MAF, allow_missing = True),
        o = ASSOC_RESULTS
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --logistic \
        --allow-no-sex \
        --hide-covar \
        --covar {input.phe} \
        --covar-name V1, V2, V3, V4 \
        --pheno {input.phe} \
        --pheno-name casecontrol \
        --out {params.o}")

rule gwas:
    input: 
        expand(ASSOC_RESULTS_EXT,cohort_misc_relate = COHORT_SUB2,
        # prs_study = PRS_STUDY, region = REGIONS,
        maf = MAF, ext = EXTENSIONS)

