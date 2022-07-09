library(tidyverse)
library(ggforce)

data <- read_csv('data/raw/misc136/snvcountHLHgenes.csv')

data_s <- data %>% 
  group_by(Sample,status) %>% 
  summarise(
    count = sum(`variant count`)
    # b = sum(`number of snvs within a gene`)
  )

# data_snv <- data %>% 
#   group_by(Sample,status) %>% 
#   summarise(
#     count = sum(`number of snvs within a gene`)
#   )

theme_set(theme_classic(base_size = 8))

data_s %>% 
  ggplot(aes(x = status, y = count )) +
  geom_violin()+
  geom_sina() +
  labs(title = 'Damaging all')




data_s %>% 
  group_by(status) %>% 
  arrange(status, count) %>% 
  top_n(5) %>% 
  write_csv('data/check/hlhhvariants.csv')
  
