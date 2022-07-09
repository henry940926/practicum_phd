library(tidyverse)
library(argparse)


parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE, nargs = '+')
parser$add_argument('--input-comb', required = TRUE, nargs = '+')
parser$add_argument('--output', required = TRUE)
args <- parser$parse_args()


# Subset the input

fined_list <- map(args$input_comb,str_subset, string = args$input)
                  

message('Load data')

data <- map(fined_list, read_table, col_names = F)

intersection <- Reduce(inner_join,data)

message('Writing output')

write_tsv(intersection,args$output, col_names = F)