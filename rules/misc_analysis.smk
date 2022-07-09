"""
Conduct the analysis

"""

MISC_SETS=['misc136','misc_cpos']

PRS_CLIN_PC_REG = 'data/result/{cohort}/pca/{prs_study}/{region}/prs_clin_pc_reg.csv'

VAR_EXP_PLOTS = 'figures/prs/{cohort}/{prs_study}/{region}/misc_var_exp.pdf'
SUMMARY_PRS_REG = 'tables/prs/{cohort}/{prs_study}/{region}/reg_summary.csv'
VAR_EXP_PLOT_RESPC = 'figures/prs/{cohort}/{prs_study}/{region}/misc_var_exp_respc.pdf'
ROC_PRS = 'figures/prs/{cohort}/{prs_study}/{region}/roc.pdf'
SUMMARY_TB_PC = 'tables/prs/{cohort}/{prs_study}/{region}/pc_assoc.csv'

rule prs_varexp:
    input:
        reg = PRS_CLIN_PC_REG,
        counts = RANGE_TABLE
    output:
        plts = VAR_EXP_PLOTS,
        summary = SUMMARY_PRS_REG,
        respc = VAR_EXP_PLOT_RESPC,
        roc = ROC_PRS, 
        pcassoc = SUMMARY_TB_PC
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/misc_ana/prs_varexp.R \
        --input {input.reg} \
        --input-count {input.counts} \
        --output {output.plts} \
        --output-long {output.summary} \
        --output-final {output.respc} \
        --output-roc {output.roc} \
        --output-assoc {output.pcassoc}")
    
PLOT_VAREXP_ALLPRS = 'figures/prs/{cohort}/{prs_comb}/{region}/varexp_all.pdf'
PLOT_VAREXP_ALLPRS_RES = 'figures/prs/{cohort}/{prs_comb}/{region}/varexp_res.pdf'


def get_prs_comb(wildcards):
    return expand(SUMMARY_PRS_REG,
    prs_study = PRS_COMB[wildcards.prs_comb], 
    allow_missing = True) 

rule plot_varexp_all:
    input:
        get_prs_comb
    output: 
        # a = PLOT_VAREXP_ALLPRS,
        res = PLOT_VAREXP_ALLPRS_RES
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/misc_ana/plot_varexp_all.R \
        --input {input} \
        --output-res {output.res}")

rule misc_analysis:
    input:
        expand(VAR_EXP_PLOTS,cohort = MISC_SETS, prs_study = PRS_STUDY, region = REGIONS),
        expand(SUMMARY_PRS_REG,cohort = MISC_SETS, prs_study = PRS_STUDY, region = REGIONS),
        expand(VAR_EXP_PLOT_RESPC,cohort = MISC_SETS, prs_study = PRS_STUDY, region = REGIONS),
        expand(ROC_PRS,cohort = MISC_SETS, prs_study = PRS_STUDY, region = REGIONS),
        expand(SUMMARY_TB_PC,cohort = MISC_SETS,prs_study = PRS_STUDY, region = REGIONS),
        # expand(PLOT_VAREXP_ALLPRS,cohort = MISC_SETS, region = REGIONS),
        expand(PLOT_VAREXP_ALLPRS_RES,cohort = MISC_SETS, 
        prs_comb = PRS_COMB.keys(), region = REGIONS)