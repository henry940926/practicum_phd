library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-bim', required = TRUE)
parser$add_argument('--input-pos', required = TRUE)
parser$add_argument('--output', required = TRUE)
parser$add_argument('--output-sum', required = TRUE)
args <- parser$parse_args()

message('Loading data')

# added to avoid scientific notation which can cause problems
options(scipen = 999)
# debug
# args <- list()
# args$input_bim <- 'data/interim/misc136/plink_merged/merged1_22.bim'
# args$input_pos <- 'data/interim/hgi/summary_stats.txt'

data <- read_table(args$input_bim,col_names = F)

summarystats <- read_table(args$input_pos,
                           col_types = cols(`#CHR`='d')
                           )

bim_merged <- data %>% 
  left_join(
    summarystats,
    by = c(
      'X1' = '#CHR',
      'X2' = 'SNP',
      'X4' = 'POS'
    )
  )

# should be matching exactly the same
stopifnot(nrow(data) == nrow(bim_merged))

## Find the SNPs that A1 and A2 match in 1000 Genomes and meta-GWAS
## Find the SNPs that A1 and A2 are flipped but still match in 1000 Genomes and meta-GWAS

# matching notations:

exact <-  'exact'
flipped <- 'flipped'
strand_flip <- 'strand_flip' # possibly

bim_merged <- bim_merged %>% 
  mutate(
    matching = case_when(
      X5 == ALT & X6 == REF ~ exact,
      X5 == REF & X6 == ALT ~ flipped,
      TRUE ~ strand_flip
    )
  )

table(bim_merged$matching)

# bim_merged %>% filter(matching == 'strand_flip') %>% View()


snp_output <- bim_merged %>% 
  filter(matching != strand_flip) %>% 
  select(X2)

summary_out <- summarystats %>% 
  filter(SNP %in% snp_output$X2)

stopifnot(nrow(summary_out)==length(snp_output$X2))

message('Writing outputs')

write_tsv(snp_output,args$output,col_names = F)
write_tsv(summary_out,args$output_sum,col_names = T)
