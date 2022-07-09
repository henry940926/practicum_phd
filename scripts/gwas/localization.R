library(tidyverse)

data <- read.table('data/temp/logistic_results.assoc.logistic',header = T)

kb <- 10000

copz2 <- data %>% 
  filter(
    CHR == 17,
    BP >= 48026167-kb & BP <=48038030+kb
  )

copz2 <- copz2 %>% 
  mutate(
    type = case_when(
      (BP>=48036402 & BP <= 48038799) | (BP>=48045002 & BP <= 48058599) ~'Promoter',
      (BP>=48030577 & BP <= 48030875) | (BP>=48043001 & BP <= 48044000) ~'Enhancer',
      TRUE ~ NA_character_
    )
  )

sig <- 0.05
theme_set(theme_bw(base_size = 8))

pl <- ggplot(copz2, aes(x = BP, y = -log10(P), color = type)) + 
  geom_hline(yintercept = (sig), color = "grey40", linetype = "dashed") + 
  geom_point(alpha = 0.75) +
  scale_y_continuous(breaks = pretty) +
  scale_color_brewer(palette = 'Set1',na.value = 'black') +
  labs(
    color = 'Type',
    y = '-log10(P-value)'
  )
pl
