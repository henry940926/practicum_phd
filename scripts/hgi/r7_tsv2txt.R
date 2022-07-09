library(tidyverse)

options(scipen = 999)

args <- list()
args$input <-  'data/raw/hgi_hospvsnon_r7/summarystats/COVID19_HGI_B1_ALL_leave_23andme_and_CGEN_20220403.tsv'

data <- read_table(args$input)

write_tsv(data,'data/raw/hgi_hospvsnon_r7/summarystats/summary_hg38.txt')
