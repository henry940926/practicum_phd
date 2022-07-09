"""

Conducts PCA for population strata

"""


PCA_INPUT = 'data/interim/{cohort}/plink_popstra/pca/merged1_22'
PCA_INPUT_EXT = PCA_INPUT + '.{ext}'
PCA_GDS = PCA_INPUT + '.gds'
rule pca_make_gds:
    input: expand(PCA_INPUT_EXT, ext = EXTENSIONS, allow_missing=True)
    output: PCA_GDS
    params: 
        i = PCA_INPUT
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/popstra/pca/get_gds.R \
        --input {params.i}")

PCA_KING = 'data/interim/{cohort}/plink_popstra/pca/king'
PCA_KING_KIN = PCA_KING + '.kin0'
rule pca_king:
    input: 
        bed = expand(PCA_INPUT_EXT, ext = 'bed', allow_missing=True),
        fam = expand(PCA_INPUT_EXT, ext = 'fam', allow_missing=True),
        bim = expand(PCA_INPUT_EXT, ext = 'bim', allow_missing=True)
    output: PCA_KING_KIN
    params: 
        i = PCA_KING
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("king -b {input.bed} --kinship \
        --prefix {params.i}")

PCA_EIGENVALUE = 'data/result/{cohort}/pca/eigenvalue.csv'
PCA_EIGENVECTOR = 'data/result/{cohort}/pca/eigenvector.csv'
rule pcair:
    input: 
        gds = PCA_GDS,
        king = PCA_KING_KIN
    output: 
        value = PCA_EIGENVALUE,
        vector = PCA_EIGENVECTOR
    threads: n_threads
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/popstra/pca/pcair.R \
        --input {input.gds} \
        --input-king {input.king} \
        --threads {threads} \
        --output-eigenvalue {output.value} \
        --output-eigenvector {output.vector}")

PCA_EIGENVALUE_TXT = 'data/result/{cohort}/pca/eigenvalue.txt'

rule eigv_txt:
    input: PCA_EIGENVALUE
    output: PCA_EIGENVALUE_TXT
    threads: 1
    resources:
        mem=4
    run:
        shell("sed '1d' {input} > {output}")

PCA_TRACY_WIDOM = 'data/result/{cohort}/pca/tracy_widom.txt'
TRACY_TABLE = 'data/raw/statistics/twtable'
rule tracy_widom:
    input: 
        eig = PCA_EIGENVALUE_TXT,
        tab = TRACY_TABLE
    output: PCA_TRACY_WIDOM
    threads: 4
    resources:
        mem=8
    run:
        shell("twstats -t {input.tab} -i {input.eig} -o {output}")

PCA_SCREEPLOT = 'figures/pca/{cohort}/screeplot.pdf'

rule pca_screeplot:
    input: PCA_EIGENVALUE
    output: PCA_SCREEPLOT
    threads: 2
    resources:
        mem=8
    run:
        shell("Rscript scripts/popstra/pca/plot_scree.R \
        --input {input} \
        --output {output}")

# merge the PCS with PRS and clinical & regression
# key step ? to merge everything...

## output 

PRS_CLIN_PC_REG = 'data/result/{cohort}/pca/{prs_study}/{region}/prs_clin_pc_reg.csv'


rule pca_merge_prs:
    input: 
        pc = PCA_EIGENVECTOR,
        prs = DF_PRS_CLIN
    output:
        PRS_CLIN_PC_REG
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/popstra/pca/prs_reg_pc.R \
        --input-prs {input.prs} \
        --input-pc {input.pc} \
        --output {output}")



PCA_SCATTER = 'figures/pca/{cohort}/{prs_study}/{region}/pcscatter.pdf'
PCA_SCATTER_FACET = 'figures/pca/{cohort}/{prs_study}/{region}/pcscatter_facet.pdf'

rule pca_scatter:
    input: 
        # different regions are the same, so pick one
        expand(PRS_CLIN_PC_REG,allow_missing=True) 
    output: 
        one = PCA_SCATTER,
        facet = PCA_SCATTER_FACET
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/popstra/pca/plot_pcs.R \
        --input {input} \
        --output {output.one} \
        --output-facet {output.facet}")

rule pca:
    input:
        expand(PCA_SCREEPLOT, cohort = COHORT_ALL),
        expand(PCA_TRACY_WIDOM, cohort = COHORT_ALL),
        expand(PCA_SCATTER, cohort = COHORT_ALL, prs_study = PRS_STUDY,
        region = REGIONS),
        expand(PCA_SCATTER_FACET, cohort = COHORT_ALL, prs_study = PRS_STUDY,
        region = REGIONS)