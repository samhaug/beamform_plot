#!/bin/bash
# Make vespagram at given azimuth for given beam file
#if [ $# != 5 ] || [ $# != 5 ]; then
if [ $# == 0 ]; then
   echo "USAGE: ./vespagram baz t_start t_end"
   echo "Makes a four-paneled vespagram for each frequency band "
   exit
fi

if [ ! -e f1_norm.beam ]; then
   echo "Need four different normalized frequency beams"
   exit
fi

if [ ! -e f1_beammax_clean ]; then
   echo "Need four different clean beammax files"
   echo "use remove_maxima_along_baz to clean a beammax file"
   exit
fi

#vesp_file=${1/.beam/_vesp}
vesp_file=filter_vesp

if [ ! -d $vesp_file ]; then mkdir $vesp_file; fi

cwd=$(pwd)
num=$(printf "%04d" $1)
echo "number: "$num
file=$vesp_file/vespagram_$num
scale=X4.25i/2.5i
region=$2/$3/0/40
cpt_dir=$SRC/beamform_plot/custom_cpt

if [ ! -e $cwd/describe ]; then
   echo "baz.dat not found computing back-azimuth"
   xh_beamdescribe f1_norm.beam > $cwd/describe
fi

alat=$(grep array_centroid_lat $cwd/describe | awk '{print $2}')
alon=$(grep array_centroid_lon $cwd/describe | awk '{print $2}')
elat=$(grep event_lat $cwd/describe | awk '{print $2}')
elon=$(grep event_lon $cwd/describe | awk '{print $2}')
baz=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $2}')
gcarc=$(vincenty_inverse $elat $elon $alat $alon | awk '{print $3}')
evdp=$(grep event_depth $cwd/describe | awk '{print $2}')

lin_max=$(grep dat1 $cwd/describe | awk '{print $4}')
lin_max=$(echo "$lin_max*0.8" | bc -l)
lin_min=$(echo "-1*$lin_max" | bc -l)

root_max=$(grep dat2 $cwd/describe | awk '{print $4}')
root_max=$(echo "$root_max*0.05" | bc -l)
sem_max=$(grep dat3 $cwd/describe | awk '{print $4}')
sem_max=$(echo "$sem_max*0.8" | bc -l)

gmt gmtset COLOR_FOREGROUND=black
#gmt makecpt -N -M -Chot -T0/$root_max/0.0001 -D -I -Z > vespagram/cmap_${2}.cpt
gmt makecpt -N -M -Chot -T0/1/0.01 -D -I -Z > $vesp_file/cmap_${1}.cpt

xh_beamvesp f1_norm.beam $1 | awk '{print $1,$2,$4}' > $vesp_file/vesp_f1_${1}.dat
xh_beamvesp f2_norm.beam $1 | awk '{print $1,$2,$4}' > $vesp_file/vesp_f2_${1}.dat
xh_beamvesp f3_norm.beam $1 | awk '{print $1,$2,$4}' > $vesp_file/vesp_f3_${1}.dat
xh_beamvesp f4_norm.beam $1 | awk '{print $1,$2,$4}' > $vesp_file/vesp_f4_${1}.dat

gmt surface $vesp_file/vesp_f1_${1}.dat -R$region -G$vesp_file/tmp_f1_${1}.grd -I0.2/0.2 -Ll0
gmt surface $vesp_file/vesp_f2_${1}.dat -R$region -G$vesp_file/tmp_f2_${1}.grd -I0.2/0.2 -Ll0
gmt surface $vesp_file/vesp_f3_${1}.dat -R$region -G$vesp_file/tmp_f3_${1}.grd -I0.2/0.2 -Ll0
gmt surface $vesp_file/vesp_f4_${1}.dat -R$region -G$vesp_file/tmp_f4_${1}.grd -I0.2/0.2 -Ll0

gmt grdimage $vesp_file/tmp_f1_${1}.grd -R$region -J$scale \
                    -BSWne+t"baz:$baz, gcarc:$gcarc, evdp:$evdp" \
                    -Bxa50f10 -Bxg50 -Byg10 -Bya10f2+l"Incidence Angle (deg)" \
                    -C$vesp_file/cmap_${1}.cpt -nl -K -Y4.5i > $file.ps

awk -v baz=$1 '{if($1==baz) print $3,$2}' f1_beammax_clean | \
        gmt psxy -J$scale -R$region -Sx2.25c -W1p,green -K -O >> $file.ps

gmt grdcontour $vesp_file/tmp_f1_${1}.grd -R$region -J$scale  \
                    -C$SRC/beamform_plot/cont_int -K -O >> $file.ps

gmt grdimage $vesp_file/tmp_f2_${1}.grd -R$region -J$scale \
                    -BSWne+t"baz slice:$1" \
                    -Bxa50f10 -Bxg50 -Byg10 -Bya10f2 \
                    -C$vesp_file/cmap_${1}.cpt -nl -K -O -X5.25i >> $file.ps

awk -v baz=$1 '{if($1==baz) print $3,$2}' f2_beammax_clean | \
        gmt psxy -J$scale -R$region -Sx2.25c -W1p,green -K -O >> $file.ps

gmt grdcontour $vesp_file/tmp_f2_${1}.grd -R$region -J$scale  \
                    -C$SRC/beamform_plot/cont_int -K -O >> $file.ps

gmt grdimage $vesp_file/tmp_f3_${1}.grd -R$region -J$scale \
                    -BSWne\
                    -Bxa50f10+l"Time (s)" -Bxg50 -Byg10 -Bya10f2+l"Incidence Angle (deg)" \
                    -C$vesp_file/cmap_${1}.cpt -nl -K -O -X-5.25i -Y-3.5i >> $file.ps

awk -v baz=$1 '{if($1==baz) print $3,$2}' f3_beammax_clean | \
        gmt psxy -J$scale -R$region -Sx2.25c -W1p,green -K -O >> $file.ps

gmt grdcontour $vesp_file/tmp_f3_${1}.grd -R$region -J$scale  \
                    -C$SRC/beamform_plot/cont_int -K -O >> $file.ps

gmt grdimage $vesp_file/tmp_f4_${1}.grd -R$region -J$scale \
                    -BSWne\
                    -Bxa50f10+l"Time (s)" -Bxg50 -Byg10 -Bya10f2 \
                    -C$vesp_file/cmap_${1}.cpt -nl -K -O -X5.25i >> $file.ps

awk -v baz=$1 '{if($1==baz) print $3,$2}' f4_beammax_clean | \
        gmt psxy -J$scale -R$region -Sx2.25c -W1p,green -K -O >> $file.ps

gmt grdcontour $vesp_file/tmp_f4_${1}.grd -R$region -J$scale  \
                    -C$SRC/beamform_plot/cont_int -K -O >> $file.ps


rm $vesp_file/vesp_${1}.dat
rm $vesp_file/tmp_${1}.grd 

