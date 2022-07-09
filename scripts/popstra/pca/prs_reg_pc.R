library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-prs', required = TRUE)
parser$add_argument('--input-pc', required = TRUE)
parser$add_argument('--output', required = TRUE, help = 'output dataframe')
args <- parser$parse_args()

# args <- list()
# args$input_pc <- 'data/result/genome1000/pca/eigenvector.csv'
# args$input_prs <- 'data/result/genome1000/prs/nohla/prs_clin_df.csv'

message('Loading data')

pcs <- read_csv(args$input_pc)
prs <- read_csv(args$input_prs)


data1 <- prs %>% 
  left_join(pcs)

n_pc <- 4 # later to adjust...

data_ana <- data1 %>% 
  nest_by(pv) %>% 
  mutate(
    m = list(lm(SCORESUM~V1+V2+V3+V4, data = data)),
    res = list(residuals(m)),
    r2 = summary(m)$r.squared
  ) %>% 
  summarise(
    data, res,r2
  ) %>% 
  ungroup()


message('Writing outputs')

write_csv(data_ana,args$output)