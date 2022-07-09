#!/bin/bash -x
#PBS -l vmem=40g,mem=40g

#PBS -l walltime=3:00:00:00

cd /hpf/largeprojects/tcagstor/projects/MSSNG_SSC_PRS/Genomes_1000_PRS

let a=1

while [ $a -le 22 ]
do
	qsub  -v PARAM1=$a Analysis2_1000Genomes.sh             
    let a=$a+1
done
