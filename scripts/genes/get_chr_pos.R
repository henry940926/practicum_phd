library(biomaRt) # have to run locally; doesn't work on hpf
library(data.table)
library(dplyr)
library(readxl)
mart <- useMart("ensembl")
mart <- useDataset("hsapiens_gene_ensembl", mart)
attributes <- c("ensembl_gene_id","start_position","end_position","strand","hgnc_symbol","chromosome_name","entrezgene_id","ucsc","band")
filters <- c("hgnc_symbol")
values <- read_excel('OneDrive - University of Toronto/projects/MISC-seq/references/Gene List for HostSeq Filtering.xlsx',
                     sheet='All') %>% c()
all.genes <- getBM(attributes=attributes, filters=filters, values=values, mart=mart)
x <- all.genes %>% 
  group_by(hgnc_symbol) %>% 
  summarise(chrom = ifelse(as.character(chromosome_name[1]) %in% c(as.character(1:22),"X"), 
                           chromosome_name[1], chromosome_name[2]), 
            start_position = min(start_position), 
            end_position = max(end_position))
fwrite(x, "23-top5000-linear_realBIS_topmed_14presynapse_genes_positions.txt", quote=F, row.names=F, col.names=T, sep="\t") # upload to hpf