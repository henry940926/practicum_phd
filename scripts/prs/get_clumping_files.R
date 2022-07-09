library(tidyverse)
library(argparse)


parser <- ArgumentParser()
parser$add_argument('--input-clump', required = TRUE)
parser$add_argument('--input-summary', required = TRUE)
parser$add_argument('--output-list', required = TRUE)
parser$add_argument('--output-summary', required = TRUE)
args <- parser$parse_args()

# args <- list()
# args$input_clump <- 'data/processed/genome1000/clumped/clump.clumped'
# args$input_summary <- 'data/interim/genome1000/plink_merged_filtered/updated_summary.txt'
# args$output_list <- 'data/processed/genome1000/clumped/clumped_snp_list.txt'
# args$output_summary <- 'data/processed/genome1000/clumped/clumped_summary_list.txt'

message('Loading data')

# added to avoid scientific notation which can cause problems
options(scipen = 999)


data <- read_table(args$input_clump,col_names = T)

summary <- read_table(args$input_summary,col_names = T)

### Step 2: Create a file with the names of the clumped SNPs (Clumped_SNPs.txt)

clumped_list <- data %>% 
  select(SNP)

### Step3: Create a file with SNPs and their corresponding p-values (Summary_Stats_Final_SNP_P.txt)

summary <- summary %>% 
  filter(
    SNP %in% clumped_list$SNP
  ) %>% 
  select(
    SNP, P = all_inv_var_meta_p
  )



message('Writing files')

write_tsv(clumped_list, args$output_list, col_names = F)
write_tsv(summary, args$output_summary,col_names = T )
