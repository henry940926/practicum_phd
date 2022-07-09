library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-bim', required = TRUE)
parser$add_argument('--output', required = TRUE)
args <- parser$parse_args()

# debug
# args <- list()
# args$input_bim <- 'data/interim/genome1000/plink_process/Genomes_1000_chr19_maf.bim'
# args$input_pos <- 'data/interim/hgi/summary_stats.txt'

message('Load files')

# Read bim file

bim <- read_table(args$input_bim,col_names = F)
# chr <- unique(bim$X1)
# print(chr)
# stopifnot(length(chr)==1)

# add name by the position # temp

bim_updated <- bim %>% 
  mutate(
    X2 = str_c(X1,'_',X4)
  )

# check the order has not changed
order_check <- sum(bim$X4==bim_updated$X4) - nrow(bim)
stopifnot(order_check==0)

message('Writing outputs')

write_tsv(bim_updated,args$output,col_names = F)
