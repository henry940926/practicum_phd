library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-snp', required = TRUE)
parser$add_argument('--input-summary', required = TRUE)
parser$add_argument('--output-snp', required = TRUE)
parser$add_argument('--output-summary', required = TRUE)
args <- parser$parse_args()


# args <- list()
# args$input_snp <- 'data/interim/genome1000/plink_merged_filtered/snps_to_keep.txt'
# args$input_summary <- 'data/interim/genome1000/plink_merged_filtered/updated_summary.txt'

# added to avoid scientific notation which can cause problems
options(scipen = 999)
data_snp <- read_table(args$input_snp, col_names = F)
data_summary <- read_table(args$input_summary, col_names = T)


# Filter out the HLA region

data_summary1 <- data_summary %>% 
  filter(
    !(`#CHR` == 6 & POS <=35000000 & POS >= 25000000)
  )

data_snp1 <- data_snp %>% 
  filter(
    X1 %in% data_summary1$SNP
  )


# Write the output

write_tsv(data_snp1, args$output_snp, col_names = F)
write_tsv(data_summary1, args$output_summary, col_names = T)