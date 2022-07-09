This repository contains the workflow for the MIS-C sequencing project.

# Conda environment

A stable enviroment is needed to prevent software updating version issues. 

`env/env.yaml` contains all the packages needed for this project.

Note that `PRSice`(https://www.prsice.info/) is also needed to be downloaded separately, because `conda` does not have this package. The r package `optparse`
also needs to be installed via a R session separately after installing all the conda packages because of version conflicts.


# Directories


# Before uploading to hpf

## Lift over

Lift the following summary stats from HG37 to HG38.

KD (`GCST90013537_buildGRCh37.tsv`)

- follow the process of `scripts/liftover/kd_lo.sh`

- upload the `Meta_GWAS_To_Lift.txt` to USCS website for liftover to HG38.

- download the failed ones as `failed1.txt` and `ucsclo1.bed`

- run `scripts/liftover/kd_liftover.py`

- for sanity check, upload `lift2.txt` to USCS again, and download the `ucsclo2.bed` for successfully liftover ones.

- `ucsclo1.bed` and `ucsclo2.bed` should match.


- run `scripts/liftover/kd_liftover2.py` to get the correct format before running the pipleine.



# Rules

## Processing data

- `snakemake summary_stats` to get summary stats files locally.


- `genome1000.smk` processes the 1000 genoeme project data

- `hgica.smk` processes the HGI data from Canada

- `misc.smk` for the MIS-C data

- `clinical.smk` for the clinical data

## PRS



- `prs.smk`



## Reports

- `reports.smk`