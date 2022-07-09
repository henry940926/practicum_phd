library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-bim', required = TRUE)
parser$add_argument('--input-pos', required = TRUE)
parser$add_argument('--output', required = TRUE)
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


# check amb

bim_merged <- bim_merged %>% 
  mutate(
    amb = case_when(X6 == 'A' & X5 == 'T' ~ 1,
                    X6 == 'T' & X5 == 'A' ~ 1,
                    X6 == 'C' & X5 == 'G' ~ 1,
                    X6 == 'G' & X5 == 'C' ~ 1,
                    TRUE ~ 0)
  ) %>% 
  filter(
    amb == 0
  )



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

## The rest of SNPs are those with alleles possibly strand flipped. Use plink to flip strands for these SNPs

# bim_merged %>% filter(matching == 'strand_flip') %>% View()


## flip strands

# bim_merged_2 <- bim_merged %>% 
#   filter(matching == 'strand_flip') %>% 
#   mutate(
#     strand_check = case_when(
#       X5 == 'A' & ALT == 'T' & X6 == 'C' & REF == 'G' ~ 1, # 1 is strand flip
#       X5 == 'A' & ALT == 'T' & X6 == 'G' & REF == 'C' ~ 1,
#       X5 == 'T' & ALT == 'A' & X6 == 'C' & REF == 'G' ~ 1,
#       X5 == 'T' & ALT == 'A' & X6 == 'G' & REF == 'C' ~ 1,
#       X5 == 'C' & ALT == 'G' & X6 == 'A' & REF == 'T' ~ 1,
#       X5 == 'C' & ALT == 'G' & X6 == 'T' & REF == 'A' ~ 1,
#       X5 == 'G' & ALT == 'C' & X6 == 'A' & REF == 'T' ~ 1,
#       X5 == 'G' & ALT == 'C' & X6 == 'T' & REF == 'A' ~ 1,
#       
#       X5 == 'A' & ALT == 'G' & X6 == 'C' & REF == 'T' ~ 2, # 2 is opposite strand flip
#       X5 == 'A' & ALT == 'C' & X6 == 'G' & REF == 'T' ~ 2,
#       X5 == 'T' & ALT == 'G' & X6 == 'C' & REF == 'A' ~ 2,
#       X5 == 'T' & ALT == 'C' & X6 == 'G' & REF == 'A' ~ 2,
#       X5 == 'C' & ALT == 'T' & X6 == 'A' & REF == 'G' ~ 2,
#       X5 == 'C' & ALT == 'A' & X6 == 'T' & REF == 'G' ~ 2,
#       X5 == 'G' & ALT == 'T' & X6 == 'A' & REF == 'C' ~ 2,
#       X5 == 'G' & ALT == 'A' & X6 == 'T' & REF == 'C' ~ 2,
#       
#       TRUE ~0
#     )
#   ) %>% 
#   mutate(
#     
#   )

prob_flip <- bim_merged %>% 
  filter(matching == strand_flip) %>% 
  select(X2)


message('Writing outputs')

write_tsv(prob_flip,args$output,col_names = F)

