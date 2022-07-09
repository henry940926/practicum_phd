# Only doing once? so not put in the pipeline

library(tidyverse)

hg19 <- read_table('data/raw/snps/snpsforpca.bim',col_names = F)

hg19_m <- hg19 %>% 
  mutate(
    bed = str_c('chr',X1,':',X4,'-',X4) # checked- without the 1based is fine also
  ) %>% 
  select(
    bed
  )

write_tsv(hg19_m,'data/raw/snps/pca_ucscliftover.bed',col_names = F)


# After first liftover

# Failed ones

failed <- read_table('data/raw/snps/hg38uscsfailed1.txt',col_names = F)

diff <- setdiff(hg19_m$bed, failed$X1) %>% tibble()

write_tsv(diff, 'data/raw/snps/pca_ucscliftover2.bed',col_names = F)

# confirm the output
hg38 <- read_table('data/raw/snps/hg38ucsc1.bed',col_names =F)


# hg382 <- read_table('data/raw/snps/hglft_genome_3cde7_738950.bed',col_names =F)
# 
# 
# identical(hg38,hg382)

# For plink
pos <- hg38 %>% 
  separate(X1,
           into = c('chr','pos1','pos2'),
           sep = ':|-') %>% 
  mutate(set = 1,
         chr = str_remove(chr, 'chr')
  )

# For VCF
pos_vcf <- hg38 %>% 
  separate(X1,
           into = c('chr','pos1','pos2'),
           sep = ':|-') %>% 
  select(1,2)

hg19_38 <- hg19 %>% 
  rename(c=X1) %>% 
  cbind(hg19_m) %>% 
  filter(
    !bed %in% failed$X1
  ) %>% 
  cbind(hg38) %>% 
  # filter(!str_detect(X1,'K')) %>% 
  separate(X1,
           into = c('chr','POS','pos2'),
           sep = ':|-') %>% 
  
  mutate(
    chr = str_remove(chr, 'chr'),
    # chr = as.numeric(chr),
    SNP = str_c(chr, '_',POS)
  ) %>% 
  select(
    `#CHR`=chr, POS,SNP, ALT = X5, REF = X6
  )


# for plink
write_tsv(pos,'data/raw/snps/pca_hg38range.txt')
# for vcf
write_tsv(pos_vcf,'data/raw/snps/pca_hg38pos.txt',col_names = F)

write_tsv(hg19_38,'data/raw/snps/pca_hg38_all.txt', col_names = T)
