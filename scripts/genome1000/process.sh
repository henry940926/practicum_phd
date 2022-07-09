#!/bin/bash -x
#PBS -l vmem=40g,mem=40g

#PBS -l walltime=3:00:00:00

cd /hpf/projects/ryeung/henry/MISC-seq

chr=$PARAM1

module load vcftools/0.1.14-6

vcftools --gzvcf /hpf/largeprojects/tcagstor/tcagstor_tmp/mssng-collab/1000G/ilmn_vcf/CCDG_13607_B01_GRM_WGS_2019-02-19_chr${chr}.recalibrated_variants.vcf.gz \
--positions snp_filter.txt \
--remove-filtered-all \
--recode --out data/filtered/Genomes_1000_chr${chr}_MAF_01

sed -i -e 's/*/N/g' data/filtered/Genomes_1000_chr${chr}_MAF_01.recode.vcf

module load plink/1.9.beta3a

plink --vcf data/filtered/Genomes_1000_chr${chr}_MAF_01.recode.vcf \
--make-bed --out data/plink/Genomes_1000_chr${chr}_MAF_01
plink --bfile data/plink/Genomes_1000_chr${chr}_MAF_01 \
--maf 0.05 --make-bed --out data/plink_process/Genomes_1000_chr${chr}