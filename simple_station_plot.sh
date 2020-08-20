#!/bin/bash

if [ $# != 2 ]; then
   echo "USAGE: ./simple_station_plot.sh xh_file region_number"
   echo "region_number: integer determining the region:"
   echo " 1: Conterminous US"
   echo " 2: Alaska"
   exit
fi

file=station_map

if [ $2 == 1 ]; then
   scale=L-100/35/33/45/7i
   region=-130/-70/24/52
elif [ $2 == 2 ]; then
   scale=A-150/65/7i
   region=-180/-130/55/75
else
   echo "region number must be 1 or 2"
   exit
fi
   
gmt pscoast -R$region -J$scale -B10 -Dc -Glightgrey -A10000 -W0.25p -K > $file.ps
xh_shorthead $1 | awk '{print $9,$8}' | gmt psxy -R$region -J$scale -Si0.2c -K -O >> $file.ps
evince $file.ps


rm stations
rm gmt.history
