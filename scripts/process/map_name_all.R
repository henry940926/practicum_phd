# Script to map SNP names from the summary stats
# to the plink bim files 

library(tidyverse)
library(argparse)


parser <- ArgumentParser()
parser$add_argument('--input-bim', required = TRUE)
parser$add_argument('--input-pos', required = TRUE)
parser$add_argument('--output', required = TRUE)
args <- parser$parse_args()


# debug
# args <- list()
# args$input_bim <- 'data/raw/misc136/hg38_mis-c_gg136.20220127.bim'
# args$input_pos <- 'data/interim/hgi/summary_stats.txt'

message('Load files')

# added to avoid scientific notation which can cause problems
options(scipen = 999)
# Read bim file

bim <- read_table(args$input_bim,col_names = F)
chr <- unique(bim$X1)


# Read original summary stats file

ss <- read_table(args$input_pos)

snp_cols <- c('#CHR','SNP','POS')

ss_chrom <- ss %>% 
  select(
    all_of(snp_cols)
  )

bim_updated <- bim %>% 
  left_join(
    ss_chrom,
    by = c('X1' = '#CHR', 'X4' = 'POS')
  ) %>% 
  mutate(
    X2 = SNP, 
    .keep = 'unused'
  )

# check the order has not changed
order_check <- sum(bim$X4==bim_updated$X4) - nrow(bim)
stopifnot(order_check==0)

message('Writing outputs')

write_tsv(bim_updated,args$output,col_names = F)