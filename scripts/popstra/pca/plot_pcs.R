library(tidyverse)
library(argparse)
library(patchwork)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--output', required = TRUE)
parser$add_argument('--output-facet', required = TRUE)
args <- parser$parse_args()


# args <- list()
# args$input <- 'data/result/genomemisc/pca/kd_clive/all/prs_clin_pc_reg.csv'

message('Loading data')

data <- read_csv(args$input)


data <- data %>% 
  rename_with(
    .fn = function(x){
      str_replace(x,'V','PC')
    },
    starts_with('V')
  ) %>% 
  mutate(
    ancestry = as_factor(ancestry)
  )
theme_set(theme_classic(base_size = 8))
theme_update(
  strip.background = element_blank(),
  strip.text = element_text(size = 6, hjust = 0),
  # axis.text.x = element_text(angle = 45,vjust = 1,hjust = 1),
  legend.position = 'bottom',
  #legend.direction = 'vertical',
  legend.box = 'vertical',
  
  aspect.ratio = 1
)


pl <- function(x,y, facet = FALSE){
  pl_scatter <- data %>% 
    ggplot(aes(x = {{x}}, y = {{y}}, color = ancestry, shape = cohort, alpha = cohort))+
    geom_point() +
    labs(
      # x = 'PC1', y = 'PC2',
      color = 'Ancestry',
      shape = 'Cohort'
    )+
    scale_x_continuous(breaks = pretty) +
    scale_y_continuous(breaks = pretty) +
    scale_color_brewer(palette = 'Set1', na.value = 'black')+
    scale_shape_manual(values = c(21,4,23))+
    scale_alpha_manual(values = c(0.08,1,1), guide = 'none')+
    coord_fixed()
  
  if (facet == TRUE){
    pl_scatter <- pl_scatter +
      facet_wrap(~cohort, ncol = 1)
  }
  
  return(pl_scatter)
}

pl_scatter12 <- pl(PC1,PC2)
pl_scatter23 <- pl(PC2,PC3)
pl_scatter13 <- pl(PC1,PC3)


plt <- pl_scatter12 + pl_scatter23 + pl_scatter13 + plot_layout(guides = 'collect')

ggsave(args$output, plt, width = 9, height = 6)

# Facet plot

pl_scatter12 <- pl(PC1,PC2, facet=TRUE)
pl_scatter23 <- pl(PC2,PC3, facet=TRUE)
pl_scatter13 <- pl(PC1,PC3, facet=TRUE)


plt <- pl_scatter12 + pl_scatter23 + pl_scatter13 + plot_layout(guides = 'collect')
l <- data$cohort %>% unique() %>% length()
ggsave(args$output_facet, plt, width = 9, height = 3*l)
