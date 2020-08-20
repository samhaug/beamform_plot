#!/bin/bash
#SBATCH --job-name=movie_maker
#SBATCH --account=jritsema1
#SBATCH --export=ALL 
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=36 
#SBATCH --cpus-per-task=1
#SBATCH --mem=180000m
#SBATCH --time=00:30:00 
#SBATCH --output=movie_maker.out
#SBATCH --error=movie_maker.err 

#Run many instances of polar_plot.sh to make slides for a movie

source ~/.bashrc
module load gmt
ulimit -s unlimited

cwd=$(pwd)
STARTTIME=$(date +%s)
echo "start time is : $(date +"%T")"
xh_beamdescribe 3comp.beam > describe 
alat=$(grep array_centroid_lat describe | awk '{print $2}')
alon=$(grep array_centroid_lon describe | awk '{print $2}')
elat=$(grep event_lat describe | awk '{print $2}')
elon=$(grep event_lon describe | awk '{print $2}')
gcarc=$(vincenty_inverse $alat $alon $elat $elon | awk '{print $3}')
h=$(grep event_depth describe | awk '{print $2}')
t=$(taup_time -mod prem -h $h -deg $gcarc -ph P --time)
t_start=$((${t%.*}-15))
t_end=$((${t%.*}+300))

baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
awk -v baz=$baz 'BEGIN{for (i=0;i<70;i+=2) print baz,i}' > $cwd/baz.dat
awk -v baz=$(echo "$baz+5" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}'  > $cwd/baz_p5.dat
awk -v baz=$(echo "$baz+10" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}' > $cwd/baz_p10.dat
awk -v baz=$(echo "$baz-5" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}'  > $cwd/baz_m5.dat
awk -v baz=$(echo "$baz-10" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}' > $cwd/baz_m10.dat

nodes=(`scontrol show hostnames $SLURM_JOB_NODELIST`)
i=0
j=0
n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs

for slide in $(seq $t_start 1 $t_end); do
    if [ $j == 10 ]; then
      j=0
      i=$((i+1))
      echo "Using next node: ${nodes[$i]}"
      if [ $i == $(($n_parallel_jobs-1)) ]; then
         echo "All nodes full."
         i=0 
         j=0
         wait
      fi
    fi
    echo "slide: $slide: $j"
    srun -n1 -N1 -w ${nodes[$i]} \ 
       ${SRC}/beamform_plot/polar_plot.sh 3comp.beam $slide &
    j=$((j+1))
done
wait
     

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

