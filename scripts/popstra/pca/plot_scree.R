library(argparse)
library(tidyverse)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--output', required = TRUE)
args <- parser$parse_args()

message('Loading data')

eigenval <- read_csv(args$input)

eigenval <- eigenval %>% 
  mutate(PC = str_c('PC',seq(1:nrow(.))),
         # sort the levels
         PC = fct_relevel(PC,str_sort(PC, numeric = TRUE)),
         var_explained = value/sum(value))

theme_set(theme_classic(base_size = 8))

pl_scree <- eigenval %>%
  slice(1:10) %>% 
  ggplot(aes(x=PC,y=var_explained))+
  geom_col()+
  scale_y_continuous(labels = scales::percent,
                     expand = c(0,0))+
  labs(
    x = 'PC', y = 'Variance explained'
  )+
  theme(
    aspect.ratio = 1
  )

message('Writing outputs')

ggsave(args$output, pl_scree, width = 3, height = 3)
