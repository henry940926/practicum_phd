library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-bim', required = TRUE)
parser$add_argument('--input-pos', required = TRUE)
parser$add_argument('--output', required = TRUE)
args <- parser$parse_args()

# debug
# args <- list()
# args$input_bim <- 'data/interim/genome1000/plink_process/Genomes_1000_chr19_maf.bim'
# args$input_pos <- 'data/interim/hgi/summary_stats.txt'

message('Load files')

# Read bim file

bim <- read_table(args$input_bim,col_names = F)
chr <- unique(bim$X1)
print(chr)
stopifnot(length(chr)==1)

# Read original summary stats file

ss <- read_table(args$input_pos)

snp_cols <- c('#CHR','SNP','POS')

ss_chrom <- ss %>% 
  filter(`#CHR` == chr) %>% 
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
