

PRS_PLOT_GENOME1000 = 'figures/prs/genome1000/{prs_study}/{region}/{ptype}/genome1000_prs_by_ancestry.pdf'
PRS_PLOT_HIST_GENOME1000 = 'figures/prs/genome1000/{prs_study}/{region}/{ptype}/genome1000_prs_by_ancestry_hist.pdf'
rule plot_prs_genome1000:
    input:
        expand(PRS_CLIN_PC_REG, cohort = 'genome1000', allow_missing=True)
    output:
        vio = PRS_PLOT_GENOME1000,
        hist = PRS_PLOT_HIST_GENOME1000
    threads: 12
    resources:
        mem=16
    run:
        shell("Rscript scripts/prs/plot_prs_genome1000_eth.R \
        --input {input} \
        --input-ptype {wildcards.ptype} \
        --output {output.vio}\
        --output-hist {output.hist}")



PL_PRS_VIO = 'figures/prs/{cohort}/{prs_study}/{region}/{ptype}/genomehgimisc136_prs_violin.pdf'
PL_PRS_HIST = 'figures/prs/{cohort}/{prs_study}/{region}/{ptype}/genomehgimisc136_prs_hist.pdf'

COHORT_SUB_COMPARISON_ACROSS = ['genomehgimisc136','genomemisc_cpos']

rule plot_prs_genomehgimisc136:
    input:
        PRS_CLIN_PC_REG
    output:
        vio = PL_PRS_VIO,
        hist = PL_PRS_HIST
    threads: 12
    resources:
        mem=16
    run:
        shell("Rscript scripts/prs/plot_prs_all.R \
        --input {input} \
        --input-ptype {wildcards.ptype} \
        --output {output.vio} \
        --output-hist {output.hist}")

rule prs_plot:
    input:
        # genome 1000 eth
        expand(PRS_PLOT_GENOME1000, region = REGIONS, 
        prs_study=PRS_STUDY, ptype = PTYPE),
        expand(PRS_PLOT_HIST_GENOME1000, region = REGIONS, 
        prs_study=PRS_STUDY, ptype = PTYPE),
        # misc+hgica+genome1000
        expand(PL_PRS_VIO, region = REGIONS, cohort = COHORT_SUB_COMPARISON_ACROSS,
        prs_study=PRS_STUDY, ptype = PTYPE),
        expand(PL_PRS_HIST, region = REGIONS, cohort = COHORT_SUB_COMPARISON_ACROSS,
        prs_study=PRS_STUDY, ptype = PTYPE)

