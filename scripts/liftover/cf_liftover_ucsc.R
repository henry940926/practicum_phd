library(tidyverse)

d1 <- read_csv('data/raw/cf/summarystats/gwas.public.txt')

l <- c('I','R')
d2 <- d1 %>% 
  filter(complete.cases(CHR, BP))# %>% 
  #filter(VAR %in% l, REF %in% l)


d3 <- d2 %>% 
  mutate(
    bed = str_c('chr',CHR,':',BP,'-',BP),
  )

  

d4 <- d3 %>% 
  select(bed)

# d4 <- d3 %>% 
#   select(CHR,BP) %>% 
#   mutate(CHR=str_c('chr',CHR),BP2=BP) %>% 
#   mutate(BP = scales::number(BP, big.mark=','),
#          BP2 = scales::number(BP2, big.mark=','))


# d4 <- d4 %>% 
#   mutate(
#     bed = str_c(CHR,':',BP,'-',BP2),
#   ) %>% 
#   select(bed)
  
  # rename(
  #   chrom = CHR,
  #   chromStart = BP,
  #   chromEnd = BP2
  # )


  #separate(col = bed,sep=':-', into = c('CHR','POS1','POS2'))

write_tsv(d4,'data/raw/cf/lifting/cf_ucscliftover.txt',col_names = F)

# Upload the above to https://genome.ucsc.edu/cgi-bin/hgLiftOver

aaaa = read_table('data/raw/cf/lifting/unlifted.bed',col_names = F)
# read 

d_lift <- read_table('data/raw/cf/lifting/cf_hg38_1.bed',col_names = F)
d_failed <- read_table('data/raw/cf/lifting/cf_lift_failed.txt',col_names = F) %>% 
  mutate(col = row_number())

d_failed <- d_failed %>% 
  filter(!X1 %in% '#Deleted') %>% 
  select(1)

d5 <- d3 %>% 
  filter(
    ! bed %in% d_failed$X1
  ) 

d6 <- d5 %>% 
  select(bed)

write_tsv(d6,'data/raw/cf/lifting/cf_ucscliftover2.txt',col_names = F)








test1 <- read_table('data/raw/cf/lifting/test1.txt',col_names = F) %>% 
  filter(!X1 %in% '#Deleted') %>% 
  select(1)


test1 <- read_table('data/raw/cf/lifting/test1_out.bed',col_names = F) 

test2 <- read_table('data/raw/cf/lifting/test2_out.bed',col_names = F) 
setdiff(test1,test2)

test3 <- read_table('data/raw/cf/lifting/Meta_GWAS_To_Lift.txt',col_names = F) 
test4 <- read_table('data/raw/cf/lifting/cf_ucscliftover.txt',col_names = F) 
identical(test3,test4)
