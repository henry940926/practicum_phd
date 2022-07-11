library(tidyverse)
library(argparse)
library(readxl)


parser <- ArgumentParser()
parser$add_argument('--input-misc', required = TRUE)
parser$add_argument('--input-genome', required = TRUE)
parser$add_argument('--input-hgica', required = TRUE)
parser$add_argument('--output', required = TRUE, help = 'output')
args <- parser$parse_args()

message('Loading data')
# 
# args <- list()
# args$input_misc <- 'data/raw/clinical/seqlist.xlsx'
# args$input_genome <- 'data/raw/genome1000/Subjects.xlsx'
# args$input_hgica <- 'data/raw/hgica/supplementary.tsv'

#a Read the clinical data

misc <- read_excel(args$input_misc)
genome1000 <- read_excel(args$input_genome)
hgica <- read_tsv(args$input_hgica)


misc <- misc %>% 
  pivot_longer(
    cols = 5:7,
    names_to = 'diagnosis',
    values_drop_na = TRUE
  ) %>% 
  select(IID = `Sample ID`, diagnosis) %>% 
  mutate(
    cohort = 'MIS-C',
    # typo from them...
    # diagnosis = str_replace(diagnosis,'postive','positive')
  )

genome1000 <- genome1000 %>% 
  select(
    IID = 1,
    ancestry = `Superpopulation code`
  ) %>% 
  mutate(
    cohort = '1000 Genomes'
  )

# HGICA eth questions: 
hgica <- hgica %>% 
  select(
    IID = `#IID`
  ) %>% 
  mutate(
    cohort = 'HGICA'
  )

#' cohorts <- c('genome1000',
#'              #'hgica',
#'              'misc')

output <- genome1000 %>% 
  plyr::rbind.fill(misc) %>% 
  plyr::rbind.fill(hgica)
  
  
message('Writing outputs')

write_csv(output, args$output, na = '')