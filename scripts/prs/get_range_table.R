library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--input-profile', nargs = '+')
parser$add_argument('--output', required = TRUE, help = 'output dataframe')
args <- parser$parse_args()


message('Loading data')

clump <- read_table(args$input)

breaks <- args$input_profile %>% 
  str_extract('(0\\.)?\\d+(?=.profile)') %>% 
  as.numeric() %>% 
  sort() %>% 
  c(0,.)

labels <- str_c('<',breaks[-1])

clump_s <- clump %>% 
  mutate(
    `P threshold` = cut(P,breaks = breaks, labels = labels)
  ) %>% 
  count(`P threshold`, .drop = FALSE) %>% 
  mutate(
    n = cumsum(n)
  )

message('Writing output')

write_csv(clump_s, args$output)