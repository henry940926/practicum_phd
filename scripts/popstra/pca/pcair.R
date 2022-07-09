library(GWASTools)
library(GENESIS)
library(argparse)
library(tidyverse)

parser <- ArgumentParser()
parser$add_argument('--input', required = TRUE)
parser$add_argument('--input-king', required = TRUE)
parser$add_argument('--threads', required = TRUE)
parser$add_argument('--output-eigenvalue', required = TRUE)
parser$add_argument('--output-eigenvector', required = TRUE)
args <- parser$parse_args()

# args <- list()
# args$input <- 'test/indep_filtered.gds'
# args$threads <- 8

message('Loading data')

geno <- GdsGenotypeReader(args$input)

genoData <- GenotypeData(geno)

iids <- getScanID(genoData)

message("Reading KING kinship coefficients")

KINGmat <- kingToMatrix(args$input_king, estimator="Kinship")

message('Performing PC-AiR')


mypcair <- pcair(genoData, kinobj = KINGmat, divobj = KINGmat, 
                 verbose = TRUE,
                 num.cores = as.numeric(args$threads))

eigenvalues <- mypcair$values %>% as_tibble()
eigenvectors <- mypcair$vectors %>% as_tibble(rownames = 'IID')

# plot(mypcair, vx = 1, vy = 2)

message('Writing outputs')

write_csv(eigenvalues, args$output_eigenvalue)
write_csv(eigenvectors, args$output_eigenvector)


