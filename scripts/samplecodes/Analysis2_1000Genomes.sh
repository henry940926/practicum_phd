#!/bin/bash -x
#PBS -l vmem=40g,mem=40g

#PBS -l walltime=3:00:00:00

cd MISC-seq

chr=$PARAM1

module load vcftools/0.1.14-6

vcftools --gzvcf /hpf/largeprojects/tcagstor/tcagstor_tmp/mssng-collab/1000G/ilmn_vcf/CCDG_13607_B01_GRM_WGS_2019-02-19_chr${chr}.recalibrated_variants.vcf.gz \
--positions /hpf/largeprojects/tcagstor/projects/MSSNG_SSC_PRS/MSSNG_PRS/SNP_To_Keep_Positions_4956783.txt \
--remove-filtered-all --keep Subjects_To_Keep_1000Genomes_516.txt \
--recode --out Genomes_1000_chr${chr}_Filter_Pass_iPSYCH_SNPs_516_Subjects
