#!/bin/bash -x
#PBS -l vmem=40g,mem=40g

#PBS -l walltime=3:00:00:00

cd /hpf/projects/ryeung/henry/MISC-seq

let a=1

while [ $a -le 22 ]
do
	qsub  -v PARAM1=$a process.sh        
    let a=$a+1
done