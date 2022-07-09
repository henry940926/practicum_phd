library(tidyverse)
library(argparse)



parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE, nargs = '+')
parser$add_argument('--output', required = TRUE, help = 'output')
args <- parser$parse_args()

# debug

# args <- list()
# args$input <- c('data/processed/genome1000/prs/nohla/prs_df.csv',
#                 'data/processed/hgica/prs/nohla/prs_df.csv',
#                 'data/processed/misc136/prs/nohla/prs_df.csv')

message('Loading data')

data <- map_dfr(
  args$input,
  read_csv,
  col_types = c('cc')
)

output <- data %>% 
  select(IID, group) %>% 
  distinct()

write_csv(output, args$output)