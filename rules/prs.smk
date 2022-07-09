CLUMPED = 'data/processed/{cohort}/clumped/{prs_study}/{region}/clump'
CLUMPED_EXT = CLUMPED + '.clumped'
PV = [5e-1,5e-2,5e-8,0.2,1,1e-1,1e-2,1e-3,1e-4,1e-6]
# extra 9e-4,8e-4,7e-4,6e-4,5e-4,4e-4,3e-4,2e-4,
UPDATED_SUMMARY_ALL = FILTERED_SUMMARY
# get rid of scientific notations
PV = [np.format_float_positional(x, trim = '-') for x in PV]
rule clumping:
    input: 
        plink = expand(MERGE_FILTERED1_EXT, ext = EXTENSIONS, allow_missing=True),
        summary = UPDATED_SUMMARY_ALL
    output: 
        CLUMPED_EXT
    params:
        i = MERGE_FILTERED1,
        o = CLUMPED
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink \
    --bfile {params.i} \
    --clump-p1 1 \
	--clump-p2 1 \
    --clump-r2 0.1 \
    --clump-kb 500 \
    --clump {input.summary} \
    --clump-snp-field SNP \
    --clump-field all_inv_var_meta_p \
    --out {params.o}")

CLUMPLIST = 'data/processed/{cohort}/clumped/{prs_study}/{region}/clumped_snp_list.txt'
CLUMPSUMMARY = 'data/processed/{cohort}/clumped/{prs_study}/{region}/clumped_summary_list.txt'
rule get_clumping_files:
    input:
        clump = CLUMPED_EXT,
        summary = UPDATED_SUMMARY_ALL
    output:
        clumplist = CLUMPLIST,
        clump_summary = CLUMPSUMMARY
    threads: 12
    resources:
        mem=32
    run:
        shell("Rscript scripts/prs/get_clumping_files.R \
        --input-clump {input.clump} \
        --input-summary {input.summary} \
        --output-list {output.clumplist} \
        --output-summary {output.clump_summary}")


PRANGE = 'data/raw/prs/prsthres.txt'
PRS = 'data/processed/{cohort}/prs/{prs_study}/{region}/prs'
PRS_RESULTS = PRS + '.{pv}'+".profile"
rule calc_prs:
    input: 
        plink = expand(MERGE_FILTERED1_EXT, ext = EXTENSIONS, allow_missing=True),
        summary = UPDATED_SUMMARY_ALL,
        prange = PRANGE,
        clumplist = CLUMPLIST
    output: expand(PRS_RESULTS, pv = PV, allow_missing=True)
    params:
        i = MERGE_FILTERED1,
        summary = UPDATED_SUMMARY_ALL,
        rangelist = PRANGE,
        summaryclumped = CLUMPSUMMARY,
        clumplist = CLUMPLIST,
        o = PRS
    threads: 12
    resources:
        mem=32
    run:
        shell("plink \
    --bfile {params.i} \
    --score {params.summary} 5 4 7 header sum center \
    --q-score-range {params.rangelist} {params.summaryclumped} \
    --extract {params.clumplist} \
    --out {params.o}")

RANGE_TABLE = 'tables/prs/{cohort}/{prs_study}/{region}/range_table.csv'

rule get_range_table:
    input:
        clump = CLUMPED_EXT,
        profile = expand(PRS_RESULTS, pv = PV, allow_missing=True)
    output:
        RANGE_TABLE
    threads: 2
    resources:
        mem=8
    run:
        shell("Rscript scripts/prs/get_range_table.R \
        --input {input.clump} \
        --input-profile {input.profile} \
        --output {output}")


### get the dataframe to plot prs

DF_PRS = 'data/result/{cohort}/prs/{prs_study}/{region}/prs_df.csv'

rule get_prs_df:
    input: 
        prs = expand(PRS_RESULTS,pv = PV, allow_missing=True)
    output: DF_PRS
    threads: 4
    resources:
        mem=10
    run:
        shell("Rscript scripts/prs/get_prs_df.R \
        --input-prs {input.prs:q} \
        --output {output}")

DF_PRS_CLIN = 'data/result/{cohort}/prs/{prs_study}/{region}/prs_clin_df.csv'

rule merge_prs_and_clin:
    input:
        prs = DF_PRS,
        clin = CLIN_MERGED
    output: DF_PRS_CLIN
    threads: 4
    resources:
        mem=10
    run:
        shell("Rscript scripts/prs/merge_prs_clin.R \
        --input-prs {input.prs} \
        --input-cl {input.clin} \
        --output {output}")

rule prs:
    input:
        expand(RANGE_TABLE, cohort = COHORT_ALL,
        prs_study=PRS_STUDY, region = REGIONS),
        expand(DF_PRS_CLIN, cohort = COHORT_ALL, 
        prs_study=PRS_STUDY, region = REGIONS)