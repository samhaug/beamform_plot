#!/bin/bash

if [ $# != 1 ]; then
   echo "Make plot of scatter coordinates with colors indicating depth"
   echo "USAGE: ./map_scatter_coords.sh ray_file"
   echo "ray_file: output of ray_finder_lookup.sh"
   exit
fi

file=scatter_coord_map
scale=G-180/45/4.5i
region=g

gmt makecpt -N -M -Cjet -T800/2900/50 -D -Z > tmp.cpt
gmt pscoast -R$region -J$scale -Dl -N1/1p -Bg30 -Dc -Gwhite -A50000 -W0.25p -K -Y2i > $file.ps
awk '{print $6,$5,$7}' $1 | gmt psxy $2 -R$region -J$scale -Si0.45c -Ctmp.cpt -K -O >> $file.ps

gmt psscale -Dx0i/1i+w12c/0.5c+jTC+h -Y-1.5i -X2i -Ctmp.cpt -Bx300+l"Depth (km)" -K -O >> $file.ps

evince $file.ps

rm gmt.history


