#!/bin/bash
# Plot baz/inc plot at given time for given beam file
if [ $# != 2 ]; then
   echo "USAGE: ./polar_plot BEAMFILE TIME"
   exit
fi
if [ ! -d slides ]; then mkdir slides; fi

cwd=$(pwd)
num=$(printf "%04d" $2)
file=slides/beamform_$num
scale=Pa4.5i
region=0/360/0/60
beam=$SRC/beamform_plot

if [ ! -e $cwd/baz.dat ]; then
   echo "baz.dat not found computing back-azimuth"
   xh_beamdescribe $1 > $cwd/describe
   alat=$(grep array_centroid_lat $cwd/describe | awk '{print $2}')
   alon=$(grep array_centroid_lon $cwd/describe | awk '{print $2}')
   elat=$(grep event_lat $cwd/describe | awk '{print $2}')
   elon=$(grep event_lon $cwd/describe | awk '{print $2}')
   baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
   awk -v baz=$baz 'BEGIN{for (i=0;i<70;i+=2) print baz,i}' > $cwd/baz.dat
   awk -v baz=$(echo "$baz+5" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}'  > $cwd/baz_p5.dat
   awk -v baz=$(echo "$baz+10" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}' > $cwd/baz_p10.dat
   awk -v baz=$(echo "$baz-5" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}'  > $cwd/baz_m5.dat
   awk -v baz=$(echo "$baz-10" | bc) 'BEGIN{for (i=0;i<70;i+=2) print baz,i}' > $cwd/baz_m10.dat
fi

root_max=$(grep dat2 $cwd/describe | awk '{print $4}')
root_max=$(echo "$root_max*0.05" | bc)
sem_max=$(grep dat3 $cwd/describe | awk '{print $4}')
sem_max=$(echo "$sem_max*0.8" | bc)

gmt makecpt -N -M -Chot -T0/$sem_max/0.01 -I -Z > slides/cmap_sem_${2}.cpt
gmt makecpt -N -M -Chot -T0/$root_max/0.01 -I -Z > slides/cmap_4th_${2}.cpt

xh_beamslice $1 $2 | awk '{print $1,$2,$5}' > slides/beam_table_sem_${2}.dat
xh_beamslice $1 $2 | awk '{print $1,$2,$4}' > slides/beam_table_4th_${2}.dat

gmt surface slides/beam_table_sem_${2}.dat -R$region -Gslides/tmp_sem_${2}.grd -I0.2/0.2 -Ll0
gmt surface slides/beam_table_4th_${2}.dat -R$region -Gslides/tmp_4th_${2}.grd -I0.2/0.2 -Ll0

gmt grdimage slides/tmp_sem_${2}.grd -R$region -J$scale  \
                    -Cslides/cmap_sem_${2}.cpt -Byg10 -Bxa45 -BN+t"$2 (s)" -nl -K > $file.ps

gmt grdcontour slides/tmp_sem_${2}.grd -R$region -J$scale  \
                    -C0.05 -K -O >> $file.ps


gmt psxy $cwd/baz.dat -R$region -J$scale -W0.6,red,-- -K -O >> $file.ps
gmt psxy $cwd/baz_p5.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps
gmt psxy $cwd/baz_p10.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps
gmt psxy $cwd/baz_m5.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps
gmt psxy $cwd/baz_m10.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps

gmt grdimage slides/tmp_4th_${2}.grd -R$region -J$scale -BN \
                    -Cslides/cmap_4th_${2}.cpt -Byg10 -Bxa45 -nl -K -O -X5.5i >> $file.ps

gmt grdcontour slides/tmp_4th_${2}.grd -R$region -J$scale  \
                    -C0.01 -K -O >> $file.ps

gmt psxy $cwd/baz.dat -R$region -J$scale -W0.6,red,-- -K -O >> $file.ps
gmt psxy $cwd/baz_p5.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps
gmt psxy $cwd/baz_p10.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps
gmt psxy $cwd/baz_m5.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps
gmt psxy $cwd/baz_m10.dat -R$region -J$scale -W0.6,grey,-- -K -O >> $file.ps


rm slides/cmap_sem_${2}.cpt
rm slides/cmap_4th_${2}.cpt
rm slides/tmp_4th_${2}.grd 
rm slides/tmp_sem_${2}.grd 
rm slides/beam_table_sem_${2}.dat
rm slides/beam_table_4th_${2}.dat

