library(tidyverse)
library(argparse)
library(scales)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE, nargs = '+')
# parser$add_argument('--output', required = TRUE)
parser$add_argument('--output-res', required = TRUE)
args <- parser$parse_args()


# args <- list()
# args$input <- c('tables/prsmisc_cpos/hgi_hospvsnon/all/reg_summary.csv',
#                 'tables/prsmisc_cpos/hgi_hospvsnon_r7/all/reg_summary.csv')



data <- args$input %>% 
  map_dfr(read_csv)

# width
w <- length(args$input)

theme_set(theme_classic(base_size = 8))
theme_update(
  strip.background = element_blank(),
  strip.text = element_text(size = 6, hjust = 0),
  axis.text.x = element_text(angle = 45,vjust = 1,hjust = 1),
  aspect.ratio = 1
)

lb <- c(
  hgi_hospvsnon = 'COVID-19 Severity PRS (r5)',
  hgi_hospvsnon_r7 = 'COVID-19 Severity PRS (r7)',
  kd_clive = 'KD PRS',
  sjia_mike = 'SJIA PRS'
)

pl_label <- labeller(
  prs_study = lb
)



data_respc <- data %>% 
  filter(type == 'respc')

pl_respc <- ggplot(data_respc, aes(x = as.factor(pv), y = r2,group=prs_study)) +
  labs(x = 'P-value threshold',
       y = "Nagelkerke's R-squared")
  # geom_col(width=0.8) +
  
s = 0.7
if ('hgi_hospvsnon' %in% data$prs_study){
  pl_respc <- pl_respc +
    geom_col(width=0.8,position = 'dodge', aes(fill = prs_study)) +
    scale_fill_brewer(palette = 'Set1',name = 'PRS Study',label = lb)+
    scale_y_continuous(breaks = pretty, expand = expansion(mult = c(0,0.2)),labels = percent) +
    geom_text(
      aes(label = str_c('p=',round(p,3))), vjust = -1.5, colour = "black", size =s ,
      position = position_dodge(width = 0.7)
    ) + 
    geom_text(
      aes(label = str_c('OR=',round(b,3))), vjust = -0.2, colour = "black", size = s,
      position = position_dodge(width = 0.7)
    ) + 
    geom_text(
      aes(label = str_c('#SNP=\n',round(n,3))), vjust = -1, colour = "darkgrey", size = s,
      position = position_dodge(width = 0.7)
    )+
    theme(
      aspect.ratio = 1/2, legend.position = 'bottom'
    )
   
} else {
  pl_respc <- pl_respc + 
    geom_col(width=0.8) +
    scale_y_continuous(breaks = pretty, expand = expansion(mult = c(0,0.1)),labels = percent) +
    geom_text(
      aes(label = str_c('p=',round(p,3))), vjust = -1.5, colour = "black", size = 1.2
    ) + 
    geom_text(
      aes(label = str_c('OR=',round(b,3))), vjust = -0.2, colour = "black", size = 1.2
    ) + 
    geom_text(
      aes(label = str_c('#SNP=\n',round(n,3))), vjust = -1, colour = "darkgrey", size = 1.2
    ) + 
    facet_wrap(~prs_study,
               scales = 'fixed',
               nrow = 1,
               labeller = pl_label)
}

pl_respc



ggsave(args$output_res,pl_respc,width = w*3, height = 3)
