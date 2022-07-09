library(readxl)
library(tidyverse)

cl <- read_excel('data/raw/clinical/Dr. Yeung Biobank Sequenced COVID_MISC_TCAG list.xlsx')
fam <- read_table('data/processed/genome1000/prs/',col_names = F)

fam$X2 %in% cl$`Sample ID`
