library(tidyverse)


# Take the intersection

a = read_tsv('data/raw/hgica/supplementary.tsv')

b = read_table('data/raw/hgica/main.psam')

data = a %>% filter(`#IID` %in% b$`#IID`)

# Filter the age

data <- data %>% 
  filter(
    Age > 0 & Age < 18
  )

