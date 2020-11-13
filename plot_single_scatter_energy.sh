#!/bin/bash

#if [ $(pwd | awk -F"/" '{print $NF}') != scatter_energy ]; then
#   echo "Must be in the scatter_energy directory"
#   exit
#fi

if [ $# != 4 ]; then
echo "not enough arguments"
exit
fi
cwd=..
alat=$(grep array_centroid_lat $cwd/describe | awk '{print $2}')
alon=$(grep array_centroid_lon $cwd/describe | awk '{print $2}')
elat=$(grep event_lat $cwd/describe | awk '{print $2}')
elon=$(grep event_lon $cwd/describe | awk '{print $2}')
baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
gcarc=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $3}')
evdp=$(grep event_depth $cwd/describe | awk '{print $2}')
title="baz=$baz gcarc=$gcarc evdp=$evdp"

scatfile=$1
penergy=$2
beamfile=$3
file=$4

echo $scatfile
echo $penergy
echo $beamfile
bmin=$(head -n1 $penergy | awk '{print $1}')
bmax=$(tail -n1 $penergy | awk '{print $1}')

proj=X14c/8cl
reg=$bmin/$bmax/0.01/100
#reg=0/365/0.01/100

tp=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P --time | awk '{print $1}')
tpp=$(taup_time -mod prem -h $evdp -deg $gcarc -ph PP --time | awk '{print $1}')
t_start=$((${tp%.*}-15))
t_end=$((${tpp%.*}+20))

vproj=X14c/6c
vreg=$t_start/$t_end/0/40

gmt set FONT_ANNOT_PRIMARY              10p,Helvetica,black
gmt set FONT_ANNOT_SECONDARY            10p,Helvetica,black
gmt set FONT_LABEL                      10p,Helvetica,black
gmt set FONT_TITLE                      12p,Helvetica,black
gmt gmtset COLOR_FOREGROUND=white

echo "File: $file"
info=($(sed "1q;d" $scatfile))
echo ${info[0]}

tail -n+2 ${scatfile} | gmt psxy -R$reg -J$proj -Bg \
               -B+t"baz: ${info[0]} inc: ${info[1]} time: ${info[2]} s" \
               -Bxa50f10 -Bya10f -W2p,red -K > $file.ps
awk -v baz=${info[0]} 'BEGIN{for (i=0;i<1000;i++) print baz,i}' |\
                gmt psxy -R$reg -J$proj -W1p,red,-- -K -O >> $file.ps

awk -v baz=$baz 'BEGIN{for (i=0;i<1000;i++) print baz,i}' |\
                gmt psxy -R$reg -J$proj -W1p,black,-- -K -O >> $file.ps

gmt psxy $penergy -R$reg -J$proj -W1p,black -K -O  >> $file.ps

echo "$title" | gmt pstext  -R$reg -J$proj -F+f12p,Helvetica,black,+cTL -K -O >> $file.ps

# PLOT VESPAGRAM SLICE
gmt gmtset COLOR_FOREGROUND=black
gmt makecpt -N -M -Chot -T0/1/0.01 -D -I -Z > cmap.cpt
xh_beamvesp $beamfile ${info[0]} | awk '{print $1,$2,$4}' > vesp.dat
gmt surface vesp.dat -R$vreg -Gvesp.grd -I0.2/0.2 -Ll0
gmt grdimage vesp.grd -R$vreg -J$vproj -BSWne+t"baz:${info[0]}"  \
                    -Bxa50f10+l"Time (s)" -Bxg50 -Byg10 -Bya10f2+l"Incidence Angle (deg)" \
                    -Ccmap.cpt -nl -K -O -Y11c >> $file.ps

gmt grdcontour vesp.grd -R$vreg -J$vproj  \
                    -C$SRC/beamform_plot/cont_int -K -O >> $file.ps

echo "${info[2]} ${info[1]}" | gmt psxy -J$scale -R$region \
          -Sx1.25c -W2p,hotpink -K -O >> $file.ps



