# define chromosome numebers

CHR = list(range(1,22+1))

# define inputs/outputs

GENOME1000_VCF = '/hpf/largeprojects/tcagstor/tcagstor_tmp/mssng-collab/1000G/ilmn_vcf/CCDG_13607_B01_GRM_WGS_2019-02-19_chr{chr}.recalibrated_variants.vcf.gz'
FILTERD_VCF = 'data/interim/genome1000/filtered/prs_{prs_study}/Genomes_1000_chr{chr}.recode.vcf'

# process the vcf


rule process_vcf:
    input: 
        vcf = GENOME1000_VCF,
        filtered_snp = FILTERED_SNP
    output: FILTERD_VCF
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell('vcftools --gzvcf {input.vcf} \
        --positions {input.filtered_snp} \
        --min-alleles 2 \
        --max-alleles 2 \
        --remove-filtered-all \
        --recode --stdout > {output}')

# need some output for sed

SEDDONE = FILTERD_VCF + '.done'

# substitute the * to N

rule sub_na:
    input: FILTERD_VCF
    output: SEDDONE
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("sed -i -e 's/*/N/g' {input}")
        shell("touch {output}")


# convert to plink files
PLINKFILES = 'data/interim/genome1000/plink/prs_{prs_study}/Genomes_1000_chr{chr}'
PLINKFILES_EXT = PLINKFILES + '.{ext}'

rule vcf_to_plink:
    input:
        vcf = FILTERD_VCF,
        sed = SEDDONE
    output: 
        expand(PLINKFILES_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        p = PLINKFILES
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --vcf {input.vcf} \
        --make-bed --out {params.p}")


# PLINKFILES_MAF = 'data/interim/genome1000/plink_process/Genomes_1000_chr{chr}' + '_maf'
# PLINKFILES_MAF_EXT = PLINKFILES_MAF + '.{ext}'
# rule maf:
#     input:
#         expand(PLINKFILES_EXT, ext = EXTENSIONS, allow_missing = True)
#     output:
#         expand(PLINKFILES_MAF_EXT, ext = EXTENSIONS, allow_missing = True)
#     params:
#         i = PLINKFILES,
#         maf = MAF,
#         o = PLINKFILES_MAF
#     threads: n_threads
#     resources:
#         mem=n_mem
#     run:
#         shell("plink --bfile {params.i} \
#         --maf {params.maf} --make-bed --out {params.o}")




# add snp ids (from hgi)

PROCESSEDBIMS = 'data/interim/genome1000/plink/prs_{prs_study}/Genomes_1000_chr{chr}.bim'
UPDATEDPLINK_BIM = 'data/interim/genome1000/plink_update/prs_{prs_study}/Genomes_1000_chr{chr}.bim'
UPDATEDPLINK_BED = 'data/interim/genome1000/plink_update/prs_{prs_study}/Genomes_1000_chr{chr}.bed'
UPDATEDPLINK_FAM = 'data/interim/genome1000/plink_update/prs_{prs_study}/Genomes_1000_chr{chr}.fam'
UPDATEDPLINK_NOSEX = 'data/interim/genome1000/plink_update/prs_{prs_study}/Genomes_1000_chr{chr}.nosex'
rule update_plink:
    input:
        bim = PROCESSEDBIMS,
        pos = FILTERED_SUMMARY
    output:
        bim = UPDATEDPLINK_BIM,
        bed = UPDATEDPLINK_BED,
        fam = UPDATEDPLINK_FAM,
        nosex = UPDATEDPLINK_NOSEX
    params:
        fam = PLINKFILES + '.fam',
        bed = PLINKFILES + '.bed',
        nosex = PLINKFILES + '.nosex'
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("Rscript scripts/process/map_name_all.R \
        --input-bim {input.bim} \
        --input-pos {input.pos} \
        --output {output.bim}")
        shell("mkdir -p data/interim/genome1000/plink_update/prs_{wildcards.prs_study}/")
        shell("rsync -avP {params.fam} \
        {params.bed} \
        {params.nosex} \
        data/interim/genome1000/plink_update/prs_{wildcards.prs_study}/")


# merge plink files

# get the list

MERGELIST = 'data/interim/genome1000/plink_update/prs_{prs_study}/mergelist.txt'

rule merge_list:
    input: expand(UPDATEDPLINK_BED, chr = CHR, allow_missing = True)
    output: MERGELIST
    threads: 1
    resources:
        mem=4
    run: 
        # remove the first line and suffix
        shell("ls -1v data/interim/genome1000/plink_update/prs_{wildcards.prs_study}/*bed | tail -n +2| sed -e's/\.bed$//' >  {output}")


MERGEDGENOME = 'data/interim/genome1000/plink_merged/prs_{prs_study}/merged1_22'
MERGEDGENOME_EXT = MERGEDGENOME +'.{ext}'
UPDATEDPLINKFILE = 'data/interim/genome1000/plink_update/prs_{prs_study}/Genomes_1000_chr{chr}'
rule merge_plink:
    input:
        mlist = MERGELIST
    output:
        expand(MERGEDGENOME_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        i = expand(UPDATEDPLINKFILE, chr = 1, allow_missing = True), # merged to the first reference
        o = MERGEDGENOME
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile  {params.i}\
        --merge-list {input.mlist} \
        --make-bed --out {params.o}")



# Filter for PCA SNPs

PCA_SNPS = 'data/raw/snps/pca_hg38pos.txt'
FILTERD_VCF_PCA = 'data/interim/genome1000/filtered/pca/Genomes_1000_chr{chr}.recode.vcf'
rule process_vcf_pca:
    input: 
        vcf = GENOME1000_VCF,
        filtered_snp = PCA_SNPS
    output: FILTERD_VCF_PCA
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell('vcftools --gzvcf {input.vcf} \
        --positions {input.filtered_snp} \
        --min-alleles 2 \
        --max-alleles 2 \
        --remove-filtered-all \
        --recode --stdout > {output}')

# need some output for sed

SEDDONE_PCA = FILTERD_VCF_PCA + '.done'

# substitute the * to N

rule sub_na_pca:
    input: FILTERD_VCF_PCA
    output: SEDDONE_PCA
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("sed -i -e 's/*/N/g' {input}")
        shell("touch {output}")


# convert to plink files
PLINKFILES_PCA = 'data/interim/genome1000/plink/pca/Genomes_1000_chr{chr}'
PLINKFILES_PCA_EXT = PLINKFILES_PCA + '.{ext}'

rule vcf_to_plink_pca:
    input:
        vcf = FILTERD_VCF_PCA,
        sed = SEDDONE_PCA
    output: 
        expand(PLINKFILES_PCA_EXT, ext = EXTENSIONS, allow_missing = True)
    params:
        p = PLINKFILES_PCA
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --vcf {input.vcf} \
        --make-bed --out {params.p}")







# add snp ids (from pca)

PROCESSEDBIMS_PCA = 'data/interim/genome1000/plink/pca/Genomes_1000_chr{chr}.bim'
UPDATEDPLINK_PCA_BIM = 'data/interim/genome1000/plink_update/pca/Genomes_1000_chr{chr}.bim'
UPDATEDPLINK_PCA_BED = 'data/interim/genome1000/plink_update/pca/Genomes_1000_chr{chr}.bed'
UPDATEDPLINK_PCA_FAM = 'data/interim/genome1000/plink_update/pca/Genomes_1000_chr{chr}.fam'
UPDATEDPLINK_PCA_NOSEX = 'data/interim/genome1000/plink_update/pca/Genomes_1000_chr{chr}.nosex'
rule update_plink_pca:
    input:
        bim = PROCESSEDBIMS_PCA
    output:
        bim = UPDATEDPLINK_PCA_BIM,
        bed = UPDATEDPLINK_PCA_BED,
        fam = UPDATEDPLINK_PCA_FAM,
        nosex = UPDATEDPLINK_PCA_NOSEX
    params:
        fam = PLINKFILES_PCA + '.fam',
        bed = PLINKFILES_PCA + '.bed',
        nosex = PLINKFILES_PCA + '.nosex'
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("Rscript scripts/genome1000/map_name_pca.R \
        --input-bim {input.bim} \
        --output {output.bim}")
        shell("mkdir -p data/interim/genome1000/plink_update/pca/")
        shell("rsync -avP {params.fam} \
        {params.bed} \
        {params.nosex} \
        data/interim/genome1000/plink_update/pca/")


# merge plink files

# get the list

MERGELIST_PCA = 'data/interim/genome1000/plink_update/pca/mergelist.txt'

rule merge_list_pca:
    input: expand(UPDATEDPLINK_PCA_BED, chr = CHR)
    output: MERGELIST_PCA
    threads: 1
    resources:
        mem=4
    run: 
        # remove the first line and suffix
        shell("ls -1v data/interim/genome1000/plink_update/pca/*bed | tail -n +2| sed -e's/\.bed$//' >  {output}")


MERGEDGENOME_PCA = 'data/interim/genome1000/plink_merged/pca/merged1_22'
MERGEDGENOME_PCA_EXT = MERGEDGENOME_PCA +'.{ext}'
UPDATEDPLINKFILE_PCA = 'data/interim/genome1000/plink_update/pca/Genomes_1000_chr{chr}'
rule merge_plink_pca:
    input:
        mlist = MERGELIST_PCA
    output:
        expand(MERGEDGENOME_PCA_EXT, ext = EXTENSIONS)
    params:
        i = expand(UPDATEDPLINKFILE_PCA, chr = 1), # merged to the first reference
        o = MERGEDGENOME_PCA
    threads: n_threads
    resources:
        mem=n_mem
    run:
        shell("plink --bfile  {params.i}\
        --merge-list {input.mlist} \
        --make-bed --out {params.o}")
