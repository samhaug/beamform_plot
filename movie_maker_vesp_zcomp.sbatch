#!/bin/bash
#SBATCH --job-name=movie_maker
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=36 
#SBATCH --cpus-per-task=1
#SBATCH --mem=180000m
#SBATCH --time=00:30:00 
#SBATCH --output=vesp_maker.out
#SBATCH --error=vesp_maker.err 

#Run many instances of vespagram.sh to make slides for a movie

source ~/.bashrc
module load gmt
ulimit -s unlimited


STARTTIME=$(date +%s)
echo "start time is : $(date +"%T")"
xh_beamdescribe :beamfile: > describe 
alat=$(grep array_centroid_lat describe | awk '{print $2}')
alon=$(grep array_centroid_lon describe | awk '{print $2}')
elat=$(grep event_lat describe | awk '{print $2}')
elon=$(grep event_lon describe | awk '{print $2}')
gcarc=$(vincenty_inverse $alat $alon $elat $elon | awk '{print $3}')
h=$(grep event_depth describe | awk '{print $2}')


#baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
#baz_start=$((${baz%.*}-60))
#baz_end=$((${baz%.*}+60))

t_start=150
t_end=400
baz_start=0
baz_start=359

nodes=(`scontrol show hostnames $SLURM_JOB_NODELIST`)
i=0
j=0
n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs

for slide in $(seq $baz_start $baz_inc $baz_end); do
    echo "slide: $slide"
    if [ $j == 25 ]; then
      j=0
      i=$((i+1))
      echo "Using next node: ${nodes[$i]}"
      if [ $i == $(($n_parallel_jobs)) ]; then
         echo "All nodes full."
         i=0 
         j=0
         wait
      fi
    fi
    srun -n1 -N1 -w ${nodes[$i]} \ 
       ${SRC}/beamform_plot/vespagram_zcomp.sh :beamfile: $slide $t_start $t_end :maxfile: &
    j=$((j+1))
done
wait
     

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

