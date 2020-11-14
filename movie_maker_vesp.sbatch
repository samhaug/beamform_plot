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

if [ $# != 2]; then
   echo "USAGE: sbatch vesp_movie_maker.sh BEAMFILE MAXFILE"
   echo "BEAMFILE: made with xh_3compbeamform"
   echo "MAXFILE: made with xh_beammax"
   exit
fi

echo $1
STARTTIME=$(date +%s)
echo "start time is : $(date +"%T")"
xh_beamdescribe $1 > describe 
alat=$(grep array_centroid_lat describe | awk '{print $2}')
alon=$(grep array_centroid_lon describe | awk '{print $2}')
elat=$(grep event_lat describe | awk '{print $2}')
elon=$(grep event_lon describe | awk '{print $2}')
gcarc=$(vincenty_inverse $alat $alon $elat $elon | awk '{print $3}')
h=$(grep event_depth describe | awk '{print $2}')
baz_inc=$(grep baz_inc describe | awk '{print $2}')
tp=$(taup_time -mod prem -h $h -deg $gcarc -ph P --time | awk '{print $1}')
tpp=$(taup_time -mod prem -h $h -deg $gcarc -ph PP --time | awk '{print $1}')
t_start=$((${tp%.*}-15))
t_end=$((${tpp%.*}+20))
echo "TIME " $t_start,$t_end

baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
baz_start=$((${baz%.*}-60))
baz_end=$((${baz%.*}+60))

nodes=(`scontrol show hostnames $SLURM_JOB_NODELIST`)
i=0
j=0
n_parallel_jobs=${#nodes[@]}
echo n_parallel_jobs: $n_parallel_jobs

for slide in $(seq $baz_start $baz_inc $baz_end); do
    echo "slide: $slide"
    #if [ "$slide" -ge "360" ]; then
    #    $slide=$(("$slide"-"360"))
    #fi
    if [ $j == 5 ]; then
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
    srun -n1 -N1 -w ${nodes[$i]} \ 
       ${SRC}/beamform_plot/vespagram.sh $1 $slide $t_start $t_end $2&
    j=$((j+1))
done
wait
     

ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")"
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

