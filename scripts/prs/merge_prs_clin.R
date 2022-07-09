library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-prs', required = TRUE)
parser$add_argument('--input-cl', required = TRUE)
parser$add_argument('--output', required = TRUE, help = 'output dataframe')
args <- parser$parse_args()

# args <- list()
# args$input_prs <- list.files('data/processed/misc136/prs/nohla',pattern = '*.profile$',full.names = T)
# args$input_cl <- 'data/raw/clinical/Dr. Yeung Biobank Sequenced COVID_MISC_TCAG list.xlsx'

message('Loading data')

data_prs <- read_csv(args$input_prs)

data_clin <- read_csv(args$input_cl)

data_out <- data_prs %>% 
  left_join(
    data_clin,
    by = 'IID'
  )

message('Writing outputs')

write_csv(data_out,args$output)