#!/bin/bash
# Make vespagram at given azimuth for given beam file

if [ $# == 0 ]; then
   echo "USAGE: ./vespagram BEAMFILE baz t_start t_end         "
   echo "                    OR                                "
   echo "USAGE: ./vespagram BEAMFILE baz t_start t_end maxfile "
   echo "       where maxfile gives coordinates of local maxima"
   echo "       generated by xh_beammax                        "
   echo "This version is for z component vespagrams with P wave at 200 seconds"
   exit
fi

vesp_file=${1/.beam/_vesp}

if [ ! -d $vesp_file ]; then mkdir $vesp_file; fi
if [ ! -e describe]; then
   xh_beamdescribe_zcomp $1 > describe
fi

cwd=$(pwd)
num=$(printf "%04d" $2)
echo "number: " $num
file=$vesp_file/vespagram_$num
scale=X6.5i/3.5i
p_min=$(awk '/p_min/ {print $2}' describe)
p_max=$(awk '/p_max/ {print $2}' describe)

region=$3/$4/$p_min/$p_max

echo $3 $4 $p_min $p_max

cpt_dir=$SRC/beamform_plot/custom_cpt

gcarc=$(awk '/gcarc/ {print $2}' describe)
evdp=$(awk '/evdp/ {print $2}' describe)

p_time=$(taup_time -mod prem -h $evdp -deg $gcarc -ph P --time) 

gmt gmtset COLOR_FOREGROUND=black

gmt makecpt -N -M -Chot -T0/1/0.01 -D -I -Z > $vesp_file/cmap_${2}.cpt

xh_beamvesp_zcomp $1 $2 $3 $4 | awk '{print $1,$3,$4}' > $vesp_file/vesp_${2}.dat

gmt surface $vesp_file/vesp_${2}.dat -R$region -G$vesp_file/tmp_${2}.grd -I0.2/0.2 -Ll0

gmt grdimage $vesp_file/tmp_${2}.grd -R$region -J$scale -BSWne+t"baz:$2, gcarc:$gcarc, evdp:$evdp" \
                      -Bxa50f10+l"Time (s)" -Bxg50 -Byg1 -Bya1f0.2+l"Slowness (s/deg)" \
                      -C$vesp_file/cmap_${2}.cpt -nl -K -P -Y5i > $file.ps

gmt grdcontour $vesp_file/tmp_${2}.grd -R$region -J$scale  \
                    -C$SRC/beamform_plot/cont_int -K -O -P >> $file.ps


