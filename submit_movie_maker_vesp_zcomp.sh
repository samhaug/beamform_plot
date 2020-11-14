#!/bin/bash

cp /home/samhaug/src/beamform_plot/movie_maker_vesp_zcomp.sbatch ./movie.sbatch

if (( $# == 0 )); then
   echo "USAGE: submit_movie_maker_vesp.sh BEAMFILE MAXFILE"
   echo "MAXFILE is optional"
   exit
fi

if (( $# == 1 )); then
   touch Maxfile
   maxfile=Maxfile
fi

if (( $# == 2 )); then
   maxfile=$1
fi

sed -i "s/:beamfile:/$1/g" ./movie.sbatch
sed -i "s/:maxfile:/$maxfile/g" ./movie.sbatch

