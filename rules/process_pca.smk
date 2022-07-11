
# Filter to the SNPs avail in PCA

## input
PCA_RANGE = 'data/raw/snps/pca_hg38range.txt'
## outputs
PCA1 = 'data/interim/{cohort_sub1}/plink_process/pca/merged1_22'
PCA1_EXT = PCA1 + '.{ext}'

rule filter_to_pca_snps:
    input: 
        plink = expand(PLINK_CHANGEFID_EXT, ext = EXTENSIONS, allow_missing = True),
        ranges = PCA_RANGE
    output: 
        expand(PCA1_EXT, ext = EXTENSIONS, allow_missing = True)
    params: 
        i = PLINK_CHANGEFID,
        o = PCA1
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --allow-extra-chr \
        --extract range {input.ranges} \
        --make-bed --out {params.o}")

# Map names to be consistent

PCA2 = 'data/interim/{cohort_sub1}/plink_merged/pca/merged1_22'
PCA2_EXT = PCA2 + '.{ext}'

rule map_to_pca_names:
    input:
        bim = expand(PCA1_EXT, ext = 'bim', allow_missing = True)
    output:
        bim = expand(PCA2_EXT, ext = 'bim', allow_missing = True),
        bed = expand(PCA2_EXT, ext = 'bed', allow_missing = True),
        fam = expand(PCA2_EXT, ext = 'fam', allow_missing = True)
        # nosex = expand(P3_EXT, ext = 'nosex', allow_missing = True)
    params:
        fam = PCA1 + '.fam',
        bed = PCA1 + '.bed',
        nosex = PCA1 + '.nosex'
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("Rscript scripts/genome1000/map_name_pca.R \
        --input-bim {input.bim} \
        --output {output.bim}")
        shell("mkdir -p data/interim/{wildcards.cohort_sub1}/plink_merged/pca/")
        shell("rsync -avP {params.fam} \
        {params.bed} \
        data/interim/{wildcards.cohort_sub1}/plink_merged/pca/")

PCA_C1 = 'data/interim/workflow/hgica_misc_pca_proc.done'

rule pre_done_pca:
    input: expand(PCA2_EXT, ext = EXTENSIONS, cohort_sub1 = COHORT_SUB1)
    output: PCA_C1
    threads: 2
    resources:
        mem=4
    shell: "touch {output}"

# output
PCA3 = 'data/interim/{cohort}/plink_maf/pca/merged1_22'
PCA3_EXT = PCA3 + '.{ext}'

# input
PCA3_MERGED= 'data/interim/{cohort}/plink_merged/pca/merged1_22'
PCA3_MERGED_EXT = PCA3_MERGED + '.{ext}'
rule maf_all_pca:
    input: 
        plink = expand(PCA3_MERGED_EXT, ext = EXTENSIONS, allow_missing = True),
        c = C1
    output: expand(PCA3_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        i = PCA3_MERGED,
        o = PCA3,
        maf = MAF
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile {params.i} \
        --maf {params.maf} \
        --make-bed \
        --out {params.o}")






SNPS_TO_FLIP_PCA = 'data/interim/{cohort}/plink_flip/pca/prob_flips.txt'
PCABIM = 'data/raw/snps/pca_hg38_all.txt'
rule check_strands1_pca:
    input:
        bim = expand(PCA3_EXT, ext = 'bim', allow_missing = True),
        summary = PCABIM
    output: 
        snp = SNPS_TO_FLIP_PCA
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/process/check_strands_all.R \
        --input-bim {input.bim} \
        --input-pos {input.summary} \
        --output {output.snp}")

PCA4 = 'data/interim/{cohort}/plink_flip/pca/flipped'
PCA4_EXT = PCA4 + '.{ext}'
rule flip_strands_pca:
    input: 
        plink = expand(PCA3_EXT, ext = EXTENSIONS, allow_missing = True),
        snp = SNPS_TO_FLIP_PCA
    output:
        expand(PCA4_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        i = PCA3,
        o = PCA4
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("plink --bfile {params.i} \
        --flip {input.snp} \
        --make-bed --out {params.o}")

SNPS_TO_KEEP1_PCA = 'data/interim/{cohort}/plink_popstra/pca/snps_to_keep.txt'
UPDATED_SUMMARY1_PCA = 'data/interim/{cohort}/plink_popstra/pca/updated_summary.txt'
rule check_strands2_pca:
    input:
        bim = expand(PCA4_EXT, ext = 'bim', allow_missing = True),
        summary = PCABIM
    output: 
        snp = SNPS_TO_KEEP1_PCA,
        summary = UPDATED_SUMMARY1_PCA
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("Rscript scripts/process/check_strands_second_all.R \
        --input-bim {input.bim} \
        --input-pos {input.summary} \
        --output {output.snp} \
        --output-sum {output.summary}")



PCA5 = 'data/interim/{cohort}/plink_popstra/pca/merged1_22'
PCA5_EXT = PCA5+'.{ext}'

rule extract_pca_snps:
    input:
        plink = expand(PCA4_EXT, ext = EXTENSIONS, allow_missing=True),
        snps = SNPS_TO_KEEP1_PCA
    output:
        expand(PCA5_EXT, ext = EXTENSIONS, allow_missing=True)
    params:
        i = PCA4,
        o = PCA5
    threads: n_threads_s
    resources:
        mem=n_mem_s
    run:
        shell("plink --bfile {params.i} \
        --extract {input.snps} \
        --make-bed --out {params.o}")

PCAFINAL = PCA5
PCAFINAL_EXT = PCAFINAL+'.{ext}'

# added snp counts - July 2022
PCA_SNP_COUNT = 'data/interim/snp_counts/pca/ori_hg38.txt'

rule count_pca_snp:
    input: PCA_RANGE
    output: PCA_SNP_COUNT
    threads: n_threads_s
    resources: 
        mem=n_mem_s
    shell: 
        '''
        wc -l {input} | awk '{{print $1-1}}' > {output}
        '''

PCA_SNP_COUNT_COHORT = 'data/interim/snp_counts/pca/{cohort}/pca_snp_counts.txt'

rule count_pca_snp_cohort:
    input: PCA5 + '.bim'
    output: PCA_SNP_COUNT_COHORT
    threads: n_threads_s
    resources: 
        mem=n_mem_s
    shell: 
        '''
        wc -l {input} | awk '{{print $1-1}}' > {output}
        '''



rule process_pca:
    input:
        expand(PCA5_EXT, ext = EXTENSIONS, cohort = COHORTS),
        PCA_SNP_COUNT,
        expand(PCA_SNP_COUNT_COHORT, cohort = COHORTS)