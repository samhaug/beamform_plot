#!/bin/bash

if [ $# != 2 ]; then
   echo "Make scatter plot map with colors indicating weights computed with xh_weight"
   echo "USAGE: ./station_weight_plot xh_file region_number"
   echo "xh_file: xh_file of subarray stations"
   echo "region_number: integer determining the region:"
   echo " 1: Conterminous US"
   echo " 2: Alaska"
   echo "This code uses xh_weightshow to dump weights from the header"
   exit
fi

file=station_weight

if [ $2 == 1 ]; then
   scale=L-100/35/33/45/7i
   region=-130/-70/24/52
elif [ $2 == 2 ]; then
   scale=A-150/65/7i
   region=-180/-130/55/75
fi

#Get lon,lat pairs of stations in xh file 
xh_shorthead $1 | awk '{print $8,$7}' | head -n -1 | tail -n+2 > stations
eq=$(xh_shorthead $1 | awk '{print $6,$5}' | head -n 2 | tail -1)

gmt makecpt -N -M -Cjet -T0.1/1/0.05 -D  -Z > tmp.cpt
gmt pscoast -R$region -J$scale -Dl -N1/1p -N2/0.5p -B10 -Dc -Gwhite -A50000 -W0.25p -K > $file.ps
xh_weightshow $1 | gmt psxy -R$region -J$scale -Si0.15c -Ctmp.cpt -K -O >> $file.ps
gmt psscale -Dx3.5i/5i+w12c/0.5c+jTC+h -Ctmp.cpt -Bx0.1+l"Weight" -K -O >> $file.ps
evince $file.ps

rm stations
rm tmp.cpt
rm gmt.history


