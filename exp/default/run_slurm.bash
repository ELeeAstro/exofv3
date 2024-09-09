#!/bin/bash

#SBATCH --job-name='test'
#SBATCH --output=fms.out
#SBATCH --error=fms.err
##SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
##SBATCH --partition=epyc2
#SBATCH --partition=bdw
#SBATCH --time=1-00:00:00

source user_config

START=0
END=8
INC=2

#for day in $(seq $START $INC $((END-INC)) ) ; do
#    bash run.bash -s -d $INC -r $day -i $net2/output_newfms/$run_name/$day/RESTART
#done
bash run.bash

