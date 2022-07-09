library(SNPRelate)
library(argparse)
library(tidyverse)


parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
args <- parser$parse_args()

# test
# args <- list()
# args$input <- 'test/final'

bed <- str_c(args$input,'.bed')
bim <- str_c(args$input,'.bim')
fam <- str_c(args$input,'.fam')
gds <- str_c(args$input,'.gds')

message('Outputting gds file')

snpgdsBED2GDS(bed.fn = bed,
              bim.fn = bim,
              fam.fn = fam,
              out.gdsfn = gds)


