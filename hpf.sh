#!/bin/bash -x
#PBS -l vmem=16g,mem=16g
#PBS -l nodes=1:ppn=8
#PBS -l walltime=72:00:00

cd /hpf/projects/ryeung/henry/misc_seq
# module load anaconda/4.6.14
source activate MISC-seq
snakemake -j 50 --cluster  \
"qsub -l nodes=1:ppn={threads} -l mem={resources.mem}g -l walltime=16:00:00 -o ./jobout -e ./jobout" \
--latency-wait 120
