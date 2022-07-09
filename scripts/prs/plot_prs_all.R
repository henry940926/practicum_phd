library(tidyverse)
library(argparse)
library(rstatix)
library(ggpubr)
library(scales)
library(patchwork)


parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--input-ptype', required = TRUE)
parser$add_argument('--output', required = TRUE, help = 'output violin')
parser$add_argument('--output-hist', required = TRUE, help = 'output histogram')
args <- parser$parse_args()

# debug

# args <- list()
# args$input <- 'data/result/genomehgimisc136/pca/nohla/prs_clin_pc_reg.csv'

message('Loading data')


data <- read_csv(args$input)

score_type <- args$input_ptype
prs_label <- case_when(
  score_type == 'raw' ~ 'Polygenic risk score (PRS)',
  score_type == 'res' ~ 'Residualized polygenic risk score (PRS)'
)

# add group
data <- data %>% 
  mutate(
    group = case_when(
      cohort == 'MIS-C' ~ diagnosis,
      TRUE ~ cohort
    ),
    outcome = case_when(
      score_type == 'raw' ~ SCORESUM,
      score_type == 'res' ~ res
    )
  )


theme_set(theme_classic(base_size = 8))
theme_update(
  strip.background = element_blank(),
  strip.text = element_text(size = 6, hjust = 0),
  axis.text.x = element_text(angle = 45,vjust = 1,hjust = 1),
  aspect.ratio = 1
)

lvs <- c('EUR','AFR','AMR','EAS','SAS',
         '1000 Genomes','HGICA',
         "COVID+ (no MIS-C)", "MIS-C positive, COVID-","MIS-C postive, COVID+"
         )
data <- data %>% 
  mutate(
    group = fct_relevel(
      group, lvs
    )
  )

pl <- data %>% 
  ggplot(aes(x = group, y = outcome )) +
  geom_violin()+
  stat_summary(fun.min = function(z){quantile(z,0.25,na.rm = T)},
               fun.max = function(z){quantile(z,0.75,na.rm = T)},
               fun = median,
               geom = "errorbar", width=0.5, size = 0.3)+
  stat_summary(fun = median,
               geom = "crossbar",width = 0.4, size = 0.3) +
  scale_color_brewer(palette = 'Set1') +
  labs(
    x = 'Group',
    y = prs_label
  )+
  facet_wrap(~pv, scale = 'free',nrow = 2)


group_levels <- data$group %>% unique()

refgroup <- case_when(
  'EUR' %in% group_levels ~ 'EUR',
  '1000 Genomes' %in% group_levels ~ '1000 Genomes',
  'HGICA' %in% group_levels ~'HGICA',
  "COVID+ (no MIS-C)" %in% group_levels ~ "COVID+ (no MIS-C)"
)

thres <- 0.05

t_test_results <- data %>% 
  nest_by(pv) %>% 
  mutate(
    ttest = list(
      t_test(
        data = data,
        outcome ~ group, paired = FALSE
        # ref.group = refgroup,
        # p.adjust.method = "bonferroni"
      ) %>% 
        add_xy_position(
          step.increase = 0.15
        ) %>%
        filter(
          p < thres
          #p.adj.signif != 'ns'
        )
      
    )
  ) %>% 
  summarise(
    ttest
  ) %>% 
  ungroup()

pl_final <- pl + 
  stat_pvalue_manual(t_test_results, 
                     label.size = 1,
                     tip.length = 0.005,
                     label = 'p'
  )
# pl_final

# Plot the histogram

data <- data %>% 
  mutate(
    group = str_replace(group, '\\,','\n')
  )

pl_data <-  data %>% 
  nest_by(pv) %>% 
  mutate(
    pl_hist = list(
      ggplot(data = data, aes(x = outcome, group = group)) + 
        geom_histogram(aes( y = stat(width*density)),color = 'black', fill = 'white') + 
        scale_y_continuous(labels = percent ) +
        facet_wrap(~group,ncol = 1) + 
        labs(
          x = str_c('PRS \n(p-value=',pv,')'),
          y = 'Proportion'
        )
    )
  )



pl_hist <- Reduce( `|`, pl_data$pl_hist)

message('Writing outputs')

ggsave(args$output, pl_final, width = 9, height = 6)
ggsave(args$output_hist, pl_hist, width = 12, height = 6)
