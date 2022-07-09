# define environments
shell.prefix("source set_env.sh ; ")
import numpy as np

rule all:
    input:
        'workflow.done'

n_threads = 32
n_mem = 32

n_threads_s = 10
n_mem_s = 16

# Available cohorts

COHORTS = [
    'genome1000', 
    'hgica','misc136','misc_cpos'
]

# Cohort comnbinations

## For first step data transformation (hgica plink2, misc to plink)
COHORT_SUB1 = ['hgica','misc136']

## For MAF all filtering
COHORT_SUB2 = ['misc136','misc_cpos']


COHORT_COMB = {
    'genomehgimisc136': ['genome1000', 'hgica','misc136'],
    'genomemisc': ['genome1000', 'misc136'],
    'genomemisc_cpos': ['genome1000', 'misc_cpos']
    # 'hgicamisc_cpos': ['hgica', 'misc_cpos']

}

COHORT_ALL = ['genome1000', 'hgica','misc136', 'misc_cpos',
'genomehgimisc136','genomemisc','genomemisc_cpos']


## For misc related cohort
COHORT_MISC_RELATED = ['genomehgimisc136',
'genomemisc', 'genomemisc_cpos'
]
## PRSice cohorts


PRS_STUDY = ['hgi_hospvsnon','kd_clive','sjia_mike',
'hgi_hospvsnon_r7']

PRS_COMB = {
    'all': ['hgi_hospvsnon_r7', 'kd_clive','sjia_mike'],
    'hgi_compare': ['hgi_hospvsnon', 'hgi_hospvsnon_r7']

}


EXTENSIONS = ['bim','bed','fam']

MAF = 0.05
REGIONS = ['all','nohla']

PTYPE = ['raw','res']

# Preprocess
include: 'rules/clinical.smk'
include: 'rules/summarystats.smk'
include: 'rules/genome1000.smk'

include: 'rules/hgica.smk'
include: 'rules/misc.smk'
include: 'rules/process.smk'
include: 'rules/process_pca.smk'
include: 'rules/merge_cohorts.smk'
include: 'rules/merge_cohorts_pca.smk'

# PRS

include: 'rules/prs.smk'

# PCA
include: 'rules/pca.smk'

# GWAS
include: 'rules/gwas.smk'

# PRSice
include: 'rules/prsice.smk'



include: 'rules/prs_plot.smk'
include: 'rules/misc_analysis.smk'
include: 'rules/reports.smk'

ruleorder: merged_filter1 > merge_combined_cohorts
ruleorder: maf_all_pca > merge_combined_cohorts_pca

rule _all:
    input:
        rules.prs.input,
        rules.pca.input,
        rules.prs_plot.input,
        rules.misc_analysis.input,
        rules.gwas.input,
        rules.prsice.input
    output: touch('workflow.done')


rule clean:
    run: 
        shell('rm -rf ./jobout workflow.done \
        data/processed \
        data/interim/*/plink* \
        data/interim/workflow \
        data/result \
        figures \
        tables')

# rule git:
#     run:
#         shell("git commit -am'minor change'")
#         shell("git push origin master")

