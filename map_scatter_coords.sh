#!/bin/bash

if [ $# != 3 ]; then
   echo "Make plot of scatter coordinates with colors indicating depth"
   echo "USAGE: ./map_scatter_coords.sh PP_file SP_file describe"
   echo "PP/SP_file: coordinates and depth of PP/SP conversions made with print_scatter_coord.sh"
   echo "describe: output file of xh_beamdescribe"
   exit
fi

file=scatter_coord_map
scale=G-180/45/4.5i
region=g

alat=$(grep array_centroid_lat $3 | awk '{print $2}')
alon=$(grep array_centroid_lon $3 | awk '{print $2}')
elat=$(grep event_lat $3 | awk '{print $2}')
elon=$(grep event_lon $3 | awk '{print $2}')

az=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $1}')
gcarc=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $3}')
gc_spread $elat $elon $az 0 $gcarc 0.5 | awk '{print $2,$1}' > arc

gmt makecpt -N -M -Cjet -T0/2700/50 -D -Z > tmp.cpt
gmt pscoast -R$region -J$scale -Dl -N1/1p -Bg30 -Dc -Gwhite -A50000 -W0.25p -K -Y2i > $file.ps
gmt psxy $2 -R$region -J$scale -Si0.45c -Ctmp.cpt -K -O >> $file.ps
gmt psxy arc -R$region -J$scale -W1p,black,--  -K -O >> $file.ps

gmt pscoast -R$region -J$scale -Dl -N1/1p -Bg30 -Dc -Gwhite -A50000 -W0.25p -K -O -X5i >> $file.ps
gmt psxy $1 -R$region -J$scale -Si0.45c -Ctmp.cpt -K -O >> $file.ps
gmt psxy arc -R$region -J$scale -W1p,black,--  -K -O >> $file.ps
gmt psscale -Dx0i/1i+w12c/0.5c+jTC+h -Y-1.5i -Ctmp.cpt -Bx300+l"Depth" -K -O >> $file.ps

evince $file.ps

rm stations
rm gmt.history


