library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--output-s', required = TRUE)
parser$add_argument('--output-f', required = TRUE)
parser$add_argument('--output-r', required = TRUE)
args <- parser$parse_args()

# args <- list()
# args$input <- 'data/raw/kd_clive/summarystats/summary_hg38.txt'
# args$output_s <- 'data/interim/hgi/summary_stats.txt'
# args$output_f <- 'data/interim/hgi/processed/snp_filter.txt'

# added to avoid scientific notation which can cause problems
options(scipen = 999)

# The KD summay stats has something weird after liftover (like 7_KI270803v1_alt)
data <- read_table(args$input,
                   col_types = cols(`#CHR`='c')
                   )

# Remove temporarily 

data <- data %>% 
  filter(
    !str_detect(`#CHR`, 'KI')
  ) %>% 
  mutate(
    `#CHR` = as.numeric(`#CHR`)
  )

# Get rid of the duplicates (triple ones) (added for the KD summary tats)

dup <- data %>% 
  count(`#CHR`,POS) %>% 
  filter(n > 1) %>% 
  select(-n)

data <- data %>% 
  anti_join(dup)




data <- data %>% 
  # code ambiguous snps
  mutate(
    amb = case_when(REF == 'A' & ALT == 'T' ~ 1,
                    REF == 'T' & ALT == 'A' ~ 1,
                    REF == 'C' & ALT == 'G' ~ 1,
                    REF == 'G' & ALT == 'C' ~ 1,
                    TRUE ~ 0)
  )

keep <-  data%>% 
  # get rid of ambiguous snps
  filter(
    amb == 0
  ) %>% 
  select(-amb)



# filter the chr and pos only
snps <- keep %>% 
  dplyr::mutate(`#CHR` = str_c('chr',`#CHR`)) %>% 
  dplyr::select(`#CHR`, POS)

# need another txt file for range

ranges <- keep %>% 
  group_by(`#CHR`) %>% 
  summarise(
    min = (POS),
    max = (POS),
    set = 1
  )

# write the summary stats
write_tsv(keep,args$output_s,col_names = T)
# write the snps
write_tsv(snps,args$output_f,col_names = F)
# write the range
write_tsv(ranges,args$output_r,col_names = F)
