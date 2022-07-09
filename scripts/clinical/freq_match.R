library(tidyverse)
library(readxl)
library(patchwork)

df_covidpos <- read_excel('data/raw/clinical/COVID positive controls.xlsx')
df_misc <- read_csv('data/raw/clinical/2022-05-10_cleaned-clinical-data.csv') 

id <- read_csv('data/result/misc_cpos/prs/kd_clive/all/prs_clin_df.csv')

id <- id %>% 
  distinct(IID, diagnosis) %>% 
  arrange(diagnosis)

r <- c('female' = 'F', 'male' = 'M')
df_covidpos <- df_covidpos %>% 
  mutate(Sex = recode(Sex, !!!r))

df_misc2 <- df_misc %>% 
  select(`Sample ID`=seqencing_ID, Sex = `Sex of child`,`Age at admission (year)`=`Age at diagnosis, years`)



df_clin <- df_covidpos %>% 
  plyr::rbind.fill(df_misc2)


ex <- c('C0397')

df_id <- id %>% 
  left_join(df_clin, by = c('IID' = 'Sample ID')) %>% 
  filter(
    !`COVID Biobank ID` %in% ex
  )

theme_set(theme_classic(base_size = 8))
theme_update(
  strip.background = element_blank(),
  strip.text = element_text(size = 6, hjust = 0),
  axis.text.x = element_text(angle = 45,vjust = 1,hjust = 1),
  aspect.ratio = 1,
  legend.position = 'bottom'
)

pl <- df_id %>% 
  ggplot(aes(x = `Age at admission (year)`, fill = diagnosis)) +
  geom_histogram(aes(y=..density..),color = 'black' ,alpha=0.5, position='identity') +
  geom_density(alpha=.2) +
  scale_fill_brewer(palette = 'Set1') +
  facet_wrap(~diagnosis,ncol=1) +
  scale_y_continuous(labels = scales::percent) + 
  labs(y = 'Proportion')
pl


pl_sex <- df_id %>% 
  filter(complete.cases(Sex)) %>% 
  ggplot(aes(x = Sex, #y = after_stat(count/sum(count)), 
             #group = diagnosis,
             fill = diagnosis)) +
  stat_count(mapping = aes(y=..prop.., group=1))+
  scale_fill_brewer(palette = 'Set1')+
  scale_y_continuous(labels = scales::percent) + 
  facet_wrap(~diagnosis,ncol=1) +
  labs(y = 'Proportion')
pl_sex

p <- pl+pl_sex
p
ggsave('figures/temp/freqm.pdf',p, height = 9, width = 9)
