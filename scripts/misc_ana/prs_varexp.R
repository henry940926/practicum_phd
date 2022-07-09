library(tidyverse)
library(DescTools)
library(broom)
library(argparse)
library(pROC)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--input-count', required = TRUE)
parser$add_argument('--output', required = TRUE)
parser$add_argument('--output-long', required = TRUE) # summary table
parser$add_argument('--output-final', required = TRUE)
parser$add_argument('--output-roc', required = TRUE)
parser$add_argument('--output-assoc', required = TRUE)
args <- parser$parse_args()


# args <- list()
# args$input <- 'data/result/misc_cpos/pca/kd_clive/all/prs_clin_pc_reg.csv'
# args$input_count <- 'tables/prs/misc_cpos/kd_clive/all/range_table.csv'

data <- read_csv(args$input)
counts <- read_csv(args$input_count)
score <- str_extract(args$input, '(?<=pca/).+?(?=/)')

# modify counts

counts <- counts %>% 
  mutate(
    pv = str_remove(`P threshold`,'<') %>% as.numeric()
  )

data11 <- data %>% 
  # filter(cohort == 'MIS-C', !diagnosis=="MIS-C positive, COVID-") %>% 
  mutate(outcome = case_when(
    str_detect(diagnosis,'MIS-C positive') ~1,
    TRUE~0)
    ) 

data1 <- data11 %>% 
  nest_by(pv) %>% 
  mutate(
    lr_res = list(glm(outcome~ res , data = data, family = binomial())),
    r2_res = PseudoR2(lr_res,'Nagelkerke'),
    p_res = tidy(lr_res,exponentiate=T) %>% filter(term=='res') %>% pluck('p.value'),
    b_res = tidy(lr_res,exponentiate=T) %>% filter(term=='res') %>% pluck('estimate'),
    lr_pc = list(glm(outcome~ V1+V2+V3+V4 , data = data, family = binomial())),
    r2_pc = PseudoR2(lr_pc,'Nagelkerke'),
    lr_scorepc = list(glm(outcome~ SCORESUM + V1+V2+V3+V4 , data = data, family =  binomial())),
    r2_scorepc = PseudoR2(lr_scorepc,'Nagelkerke'),
    p_scorepc = tidy(lr_scorepc,exponentiate=T) %>% filter(term=='SCORESUM') %>% pluck('p.value'),
    b_scorepc = tidy(lr_scorepc,exponentiate=T) %>% filter(term=='SCORESUM') %>% pluck('estimate'),
    lr_respc = list(glm(outcome~ res + V1+V2+V3+V4 , data = data, family =  binomial())),
    r2_respc = PseudoR2(lr_respc,'Nagelkerke'),
    p_respc = tidy(lr_respc,exponentiate=T) %>% filter(term=='res') %>% pluck('p.value'),
    b_respc = tidy(lr_respc,exponentiate=T) %>% filter(term=='res') %>% pluck('estimate'),
    roc_respc = list(roc(lr_respc$y,as.vector(predict(lr_respc,type='response')))),
    auc_respc = list(roc_respc$auc),
    roplt_respc = list(
      ggroc(roc_respc) +
        labs(x = "1 - Specificity",
             y = "Sensitivity") +
        annotate(
          'text', x = 1, y = 1,
          hjust = 0, vjust = 1,
          label = str_c('AUC=',round(auc_respc,3))
        )
      
    )
  ) %>% 
  mutate(
    r2_scorepc = r2_scorepc - r2_pc,
    r2_respc = r2_respc- r2_pc
  ) %>% 
  select(
    -r2_pc
  )

data_long <- data1 %>% 
  select(
    pv, starts_with('r2'),starts_with('p'), starts_with('b')
  ) %>% 
  pivot_longer(
    -1,
    names_to = c('.value','type'),
    names_pattern = '(.+)_(.+)'
  )%>% 
  left_join(counts) %>% 
  mutate(prs_study = score)


# Plot


theme_set(theme_classic(base_size = 8))
theme_update(
  strip.background = element_blank(),
  strip.text = element_text(size = 6, hjust = 0),
  axis.text.x = element_text(angle = 45,vjust = 1,hjust = 1),
  aspect.ratio = 1
)

lb <- c(
  res = 'Residual',
  respc = 'Residual + PCs',
  scorepc = 'PRS + PCs'
)

pl_label <- labeller(
  type = lb
)

# Multiple options to model

pl <- ggplot(data_long, aes(x = as.factor(pv), y = r2)) + 
  geom_col(width=0.8) +
  scale_y_continuous(breaks = pretty, expand = expansion(mult = c(0,0.1))) +
  labs(x = 'P-value threshold',
       y = "Nagelkerke's R-squared")+
  geom_text(
    aes(label = str_c('p=',round(p,3))), vjust = -1.5, colour = "black", size = 0.8
  ) + 
  geom_text(
    aes(label = str_c('OR=',round(b,3))), vjust = -0.2, colour = "black", size = 0.8
  )+
  facet_wrap(~type,labeller = pl_label)

# Final model

data_respc <- data_long %>% 
  filter(type == 'respc')

pl_respc <- ggplot(data_respc, aes(x = as.factor(pv), y = r2)) + 
  geom_col(width=0.8) +
  scale_y_continuous(breaks = pretty, expand = expansion(mult = c(0,0.1))) +
  labs(x = 'P-value threshold',
       y = "Nagelkerke's R-squared")+
  geom_text(
    aes(label = str_c('p=',round(p,3))), vjust = -1.5, colour = "black", size = 1.5
  ) + 
  geom_text(
    aes(label = str_c('OR=',round(b,3))), vjust = -0.2, colour = "black", size = 1.5
  )

# Association between case/control vs PC

data_pc <- data1 %>% 
  select(pv, lr_pc) %>% 
  mutate(
    summary_tb = list(tidy(lr_pc,exponentiate=T))
  ) %>% 
  select(summary_tb) %>% 
  summarise(
    summary_tb
  ) %>% 
  ungroup() %>%
  select(-1) %>% 
  distinct()

# Extract ROC curve with the highest variation explained:

pl_roc <- data1 %>% 
  ungroup() %>% 
  filter(
    r2_respc == max(r2_respc)
  ) 

pl_roc <- pl_roc$roplt_respc[[1]]

ggsave(args$output,pl,width = 6, height = 3)
ggsave(args$output_final,pl_respc,width = 3, height = 3)
ggsave(args$output_roc,pl_roc,width = 3, height = 3)
write_csv(data_pc, args$output_assoc)
write_csv(data_long, args$output_long)