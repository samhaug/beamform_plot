#!/bin/bash
#SBATCH --job-name=movie_maker
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=1 
#SBATCH --cpus-per-task=1
#SBATCH --mem=180000m
#SBATCH --time=10:00:00 
#SBATCH --output=movie_maker.out
#SBATCH --error=movie_maker.err 


#NOT NEEDED SINCE 03/01/2020.

source ~/.bashrc
module load gmt
ulimit -s unlimited 

STARTTIME=$(date +%s)
echo "start time is : $(date +"%T")"

n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs

for slide in $(seq 450 1 600); do
    srun -n1 -N1 ${SRC}/beamform_plot/polar_plot.sh 3comp.beam $slide > /dev/null & wait
done
     
ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

