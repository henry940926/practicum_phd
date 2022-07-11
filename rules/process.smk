
# Filter to the SNPs avail in HGI

## inputs
PLINK_ALL = 'data/interim/{cohort_sub1}/plink/all'
PLINK_ALL_EXT = PLINK_ALL + '.{ext}'

UPDATE_FID = 'data/interim/{cohort_sub1}/plink/update_ids.txt'

rule get_fid_file:
    input:
        bed = expand(PLINK_ALL_EXT, ext = 'bed', allow_missing = True),
        fam = expand(PLINK_ALL_EXT, ext = 'fam', allow_missing = True),
        bim = expand(PLINK_ALL_EXT, ext = 'bim', allow_missing = True),
    output: 
        UPDATE_FID
    threads: 2
    resources:
        mem=8
    shell: 
        '''
        awk '{{print $1"\t"$2"\t"$2"\t"$2}}' {input.fam} > {output}
        '''

## output

PLINK_CHANGEFID = 'data/interim/{cohort_sub1}/plink/all_changeid'
PLINK_CHANGEFID_EXT = PLINK_CHANGEFID  + '.{ext}'
rule change_fam_id:
    input:
        plink = expand(PLINK_ALL_EXT, ext = EXTENSIONS, allow_missing = True),
        ids = UPDATE_FID
    output: 
        expand(PLINK_CHANGEFID_EXT, ext = EXTENSIONS, allow_missing = True)
    params: 
        i = PLINK_ALL,
        o = PLINK_CHANGEFID
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --update-ids {input.ids} \
        --make-bed --out {params.o}")

## outputs
P2 = 'data/interim/{cohort_sub1}/plink_process/prs_{prs_study}/merged1_22'
P2_EXT = P2 + '.{ext}'

rule filter_to_prs_snps:
    input: 
        plink = expand(PLINK_CHANGEFID_EXT, ext = EXTENSIONS, allow_missing = True),
        ranges = FILTERED_RANGE
    output: 
        expand(P2_EXT, ext = EXTENSIONS, allow_missing = True)
    params: 
        i = PLINK_CHANGEFID,
        o = P2
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --extract range {input.ranges} \
        --make-bed --out {params.o}")

# Map names to be consistent

P3_1 = 'data/interim/{cohort_sub1}/plink_merged/prs_{prs_study}/merged1_22'
P3_1_EXT = P3_1 + '.{ext}'

rule map_to_prs_names:
    input:
        bim = expand(P2_EXT, ext = 'bim', allow_missing = True),
        pos = FILTERED_SUMMARY
    output:
        bim = expand(P3_1_EXT, ext = 'bim', allow_missing = True),
        bed = expand(P3_1_EXT, ext = 'bed', allow_missing = True),
        fam = expand(P3_1_EXT, ext = 'fam', allow_missing = True)
        # nosex = expand(P3_EXT, ext = 'nosex', allow_missing = True)
    params:
        fam = P2 + '.fam',
        bed = P2 + '.bed',
        nosex = P2 + '.nosex'
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("Rscript scripts/process/map_name_all.R \
        --input-bim {input.bim} \
        --input-pos {input.pos} \
        --output {output.bim}")
        shell("mkdir -p data/interim/{wildcards.cohort_sub1}/plink_merged/prs_{wildcards.prs_study}/")
        shell("rsync -avP {params.fam} \
        {params.bed} \
        data/interim/{wildcards.cohort_sub1}/plink_merged/prs_{wildcards.prs_study}/")

C1 = 'data/interim/workflow/hgica_misc_proc.done'

rule pre_done:
    input: expand(P3_1_EXT, ext = EXTENSIONS, cohort_sub1 = COHORT_SUB1, prs_study=PRS_STUDY)
    output: C1
    threads: 2
    resources:
        mem=8
    shell: "touch {output}"


P3 = 'data/interim/{cohort}/plink_maf/prs_{prs_study}/merged1_22'
P3_EXT = P3 + '.{ext}'
P2_MERGED= 'data/interim/{cohort}/plink_merged/prs_{prs_study}/merged1_22'
P2_MERGED_EXT = P2_MERGED + '.{ext}'
rule maf_all:
    input: 
        plink = expand(P2_MERGED_EXT, ext = EXTENSIONS, allow_missing = True),
        c = C1
    output: expand(P3_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        i = P2_MERGED,
        o = P3,
        maf = MAF
    threads: 16
    resources:
        mem=32
    run:
        shell("plink --bfile {params.i} \
        --maf {params.maf} \
        --make-bed \
        --out {params.o}")

# check strands



SNPS_TO_FLIP = 'data/interim/{cohort}/plink_flip/prs_{prs_study}/prob_flips.txt'

rule check_strands1:
    input:
        bim = expand(P3_EXT, ext = 'bim', allow_missing = True),
        summary = FILTERED_SUMMARY
    output: 
        snp = SNPS_TO_FLIP
    threads: 16
    resources:
        mem=32
    run:
        shell("Rscript scripts/process/check_strands_all.R \
        --input-bim {input.bim} \
        --input-pos {input.summary} \
        --output {output.snp}")

P4 = 'data/interim/{cohort}/plink_flip/prs_{prs_study}/flipped'
P4_EXT = P4 + '.{ext}'
rule flip_strands:
    input: 
        plink = expand(P3_EXT, ext = EXTENSIONS, allow_missing = True),
        snp = SNPS_TO_FLIP
    output:
        expand(P4_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        i = P3,
        o = P4
    threads: 16
    resources:
        mem=32
    run:
        shell("plink --bfile {params.i} \
        --flip {input.snp} \
        --make-bed --out {params.o}")

SNPS_TO_KEEP1 = 'data/interim/{cohort}/plink_merged_filtered/prs_{prs_study}/all/snps_to_keep.txt'
UPDATED_SUMMARY1 = 'data/interim/{cohort}/plink_merged_filtered/prs_{prs_study}/all/updated_summary.txt'
rule check_strands2:
    input:
        bim = expand(P4_EXT, ext = 'bim', allow_missing = True),
        summary = FILTERED_SUMMARY
    output: 
        snp = SNPS_TO_KEEP1,
        summary = UPDATED_SUMMARY1
    threads: 16
    resources:
        mem=32
    run:
        shell("Rscript scripts/process/check_strands_second_all.R \
        --input-bim {input.bim} \
        --input-pos {input.summary} \
        --output {output.snp} \
        --output-sum {output.summary}")


# # Exclude the hla region

SNPS_TO_KEEP_NOHLA1 = 'data/interim/{cohort}/plink_merged_filtered/prs_{prs_study}/nohla/snps_to_keep.txt'
UPDATED_SUMMARY_NOHLA1 = 'data/interim/{cohort}/plink_merged_filtered/prs_{prs_study}/nohla/updated_summary.txt'


rule exclude_hla1:
    input:
        snp = SNPS_TO_KEEP1,
        summary = UPDATED_SUMMARY1,
    output:
        snp = SNPS_TO_KEEP_NOHLA1,
        summary = UPDATED_SUMMARY_NOHLA1
    threads: 12
    resources:
        mem=16
    run:
        shell("Rscript scripts/process/filter_hla.R \
        --input-snp {input.snp} \
        --input-summary {input.summary} \
        --output-snp {output.snp} \
        --output-summary {output.summary}")

MERGE_FILTERED1 = 'data/interim/{cohort}/plink_merged_filtered/prs_{prs_study}/{region}/final'
MERGE_FILTERED1_EXT = MERGE_FILTERED1+'.{ext}'
SNPS_TO_KEEP_ALL1 = 'data/interim/{cohort}/plink_merged_filtered/prs_{prs_study}/{region}/snps_to_keep.txt'
REGIONS = ['all','nohla']

rule merged_filter1:
    input:
        plink = expand(P4_EXT, ext = EXTENSIONS, allow_missing=True),
        snps = SNPS_TO_KEEP_ALL1
    output:
        expand(MERGE_FILTERED1_EXT, ext = EXTENSIONS, allow_missing=True)
    params:
        i = P4,
        o = MERGE_FILTERED1
    threads: 12
    resources:
        mem=16
    run:
        shell("plink --bfile {params.i} \
        --extract {input.snps} \
        --make-bed --out {params.o}")

SNP_COUNT_COHORT = 'data/interim/snp_counts/{prs_study}/{cohort}/{region}/snp_counts.txt'

rule count_snp_cohort:
    input: MERGE_FILTERED1 + '.bim'
    output: SNP_COUNT_COHORT
    threads: n_threads_s
    resources: 
        mem=n_mem_s
    shell: 
        '''
        wc -l {input} | awk '{{print $1-1}}' > {output}
        '''


rule process:
    input:
        expand(MERGE_FILTERED1_EXT,cohort = COHORTS,
        prs_study = PRS_STUDY,
        ext = EXTENSIONS, region = REGIONS),
        expand(SNP_COUNT_COHORT,cohort = COHORTS,
        prs_study = PRS_STUDY,
        region = REGIONS)