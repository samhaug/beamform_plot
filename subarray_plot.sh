#!/bin/bash

if [ ! -f subarray_*.txt ]; then
   echo "Needs at least one subarray_?.txt file"
   exit
fi
if [ $# != 1 ]; then
   echo "USAGE: ./subarray_plot region_number"
   echo "Needs at least one subarray_?.txt file"
   echo "region_number: integer determining the region:"
   echo " 1: Conterminous US"
   echo " 2: Alaska"
   exit
fi

file=subarray_map

if [ $1 == 1 ]; then
   scale=L-100/35/33/45/7i
   region=-130/-70/24/52
elif [ $1 == 2 ]; then
   scale=A-150/65/7i
   region=-180/-130/55/75
else
   echo "region number must be 1 or 2"
   exit
fi
   

color=(red blue green purple orange yellow brown hotpink cyan magenta)

j=0
gmt pscoast -R$region -J$scale -B10 -Dc -Glightgrey -A10000 -W0.25p -K > $file.ps
for i in subarray_*.txt; do
   awk '{print $2,$1}' $i | gmt psxy -R$region -J$scale -Si0.2c -G${color[$j]} -K -O >> $file.ps
   j=$((j+1))
done

evince $file.ps

rm stations
rm gmt.history
