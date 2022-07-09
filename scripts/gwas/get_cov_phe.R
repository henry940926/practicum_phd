library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--output', required = TRUE)
parser$add_argument('--output-nofid', required = TRUE)
args <- parser$parse_args()


data <- read_csv(args$input)



data <- data %>% 
  # filter(
  #   cohort == 'MIS-C'
  # ) %>% 
  mutate(
    # FID = 0,
    casecontrol = case_when(
      str_detect(diagnosis, 'MIS-C positive') ~ 2,
      TRUE ~ 1
      # diagnosis == 'COVID+ (no MIS-C)' ~ 1
    )
  ) %>% 
  select(
    FID, IID, V1:V32, casecontrol
  ) %>% 
  distinct()

data_no_fid <- data %>% 
  mutate(
    FID = 0
  )


write_tsv(data, args$output)
write_tsv(data_no_fid, args$output_nofid)