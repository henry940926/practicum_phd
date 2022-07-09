library(tidyverse)
library(argparse)

parser <- ArgumentParser()
parser$add_argument('--input-prs', required = TRUE, nargs = '+')
# parser$add_argument('--input-cohort')
parser$add_argument('--output', required = TRUE, help = 'output dataframe')
args <- parser$parse_args()

message('Loading data')

# Get the PRS .profile and add a column for pvalue

data <- map_dfr(
  args$input_prs,
  .f = function(x){
    y <- read_table(x) %>% 
      mutate(pv = str_extract(x,'(0\\.)?\\d+(?=.profile)') %>% as.numeric())
    return(y)
  }
) 

# if (!is.null(args$input_cohort)){
#   data <- data%>% 
#     mutate(group = args$input_cohort)
# }

message('Writing outputs')

write_csv(data,args$output)