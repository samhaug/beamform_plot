#!/bin/bash
# Plot scatter location given timefile and target time
if [ $# != 2 ]; then
   echo "USAGE: ./plot_scatter_location timefile res"
   echo "timefile: created by scatter_locate.sh "
   echo "res: integer 1,2,3 for low/med/high res "
   echo "     1 = 2/100 "
   echo "     2 = 1/20 "
   echo "     3 = 0.5/5 "
   echo "     Do this to match the grid search specified in scatter_locate.sh "
   exit
fi

if [ $2 == 1 ]; then
  res=2/100
elif [ $2 == 2 ]; then
  res=1/20
elif [ $2 == 3 ]; then
  res=0.5/5
else
  echo "res must be 1,2 or 3"
  exit
fi

file=$1
scale=Pa4.5i
region=0/85/3481/6371

gmt gmtset COLOR_FOREGROUND=white
gmt gmtset COLOR_BACKGROUND=black

gmt makecpt -N -M -Chot -T0/20/1 -Z > cmap.cpt

awk '{print $1,$4,$5}' $file > pp_times
awk '{print $1,$4,$6}' $file > sp_times

gmt xyz2grd sp_times -R$region -Gtmp.grd -I$res
gmt grdimage tmp.grd -R$region -J$scale -Bx10 -By500 -Ccmap.cpt -nl -Q -K > out.ps
gmt psxy ${SRC}/beamform_plot/400.dat -R$region -J$scale -W1p,gray -K -O >> out.ps
gmt psxy ${SRC}/beamform_plot/670.dat -R$region -J$scale -W1p,gray -K -O >> out.ps
#gmt psxy p_path.dat -R$region -J$scale -W1p,black -K -O >> out.ps

echo S-P | gmt pstext -R1/10/1/10 -JX12 -F+cTL+f24p -K -O >> out.ps

gmt xyz2grd pp_times -R$region -Gtmp.grd -I$res
gmt grdimage tmp.grd -R$region -J$scale -Bx10 -By500 \
                     -Ccmap.cpt -nl -Q -K -O -X5i >> out.ps
gmt psxy ${SRC}/beamform_plot/400.dat -R$region -J$scale -W1p,gray -K -O >> out.ps
gmt psxy ${SRC}/beamform_plot/670.dat -R$region -J$scale -W1p,gray -K -O >> out.ps
#gmt psxy pp_path.dat -R$region -J$scale -W1p,black -K -O >> out.ps
#gmt psxy p_path.dat -R$region -J$scale -W1p,black -K -O >> out.ps

echo P-P | gmt pstext -R1/10/1/10 -JX12 -F+cTL+f24p -K -O >> out.ps

evince out.ps

rm gmt.conf
rm cmap.cpt
rm tmp.grd
rm gmt.history


