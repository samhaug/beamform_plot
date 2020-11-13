#!/bin/bash                                                                

if [ $# != 2 ]; then
   echo "USAGE: ./scatter_depth_histogram.sh PHASE CUTOFF"
   echo "where PHASE is P or S"
   echo "won't include arrivals with amplitude less than CUTOFF"  
   exit
fi

#if [[ $1 != "P" || $1 != "S" ]]; then
#   echo "PHASE must be P or S"
#   exit
#fi
                                                                                
gmt gmtset FONT_LABEL=14p,Helvetica,black
reg=-R800/2900/0/10
proj=-JX5.0/5.0                                                           
bord=-Ba500f100:"Depth\040(km)":/a2f0.5:"Fraction":WS                      

reg1=-R800/2900/0/100
proj=-JX5.0/5.0                                                           
bord1=-Ba500f100:"Depth\040(km)":/a25f5:'Cumulative':WS                      

regf=-R800/2900/0/10
projf=-JX5.0/5.0                                                           
bordf=-Ba500f100:"":/a2f0.5:"Fraction":WS                      

regc=-R800/2900/0/100
proj=-JX5.0/5.0                                                           
bordc=-Ba500f100:"":/a25f5:'Cumulative':WS                      
                                                                            
w=50                                                                  

if [ $1 == "P" ]; then
   cat E*/SUB*/f1_beammax_P_ray | awk -v c=$2 '$4 > c {print $7}' > f1_file
   cat E*/SUB*/f2_beammax_P_ray | awk -v c=$2 '$4 > c {print $7}' > f2_file
   cat E*/SUB*/f3_beammax_P_ray | awk -v c=$2 '$4 > c {print $7}' > f3_file
   cat E*/SUB*/f4_beammax_P_ray | awk -v c=$2 '$4 > c {print $7}' > f4_file
fi

if [ $1 == "S" ]; then
   cat E*/SUB*/f1_beammax_S_ray | awk '{print $7}' > f1_file
   cat E*/SUB*/f2_beammax_S_ray | awk '{print $7}' > f2_file
   cat E*/SUB*/f3_beammax_S_ray | awk '{print $7}' > f3_file
   cat E*/SUB*/f4_beammax_S_ray | awk '{print $7}' > f4_file
fi
                                                                                
# -W is bin width                                                               
# -L is line                                                                    
# -S is stair-step                                                              
# Z=1 is frequency percent                                                      
                                                                                
Xoff=4.0i
Yoff=2.5i

#f4 hist 
gmt pshistogram f4_file $bord $proj $reg -W$w -L,0 -S -Z1 -P -Y1i -V -K >  plot.ps
#f4 cumulative
gmt pshistogram f4_file $bord1 $proj $reg1 -W$w -L,0 -S -Z1 -Q -X$Xoff -O -P -V -K >> plot.ps

#f3 hist
gmt pshistogram f3_file $bordf $proj $regf -W$w -L,0 -S -Z1 -Y$Yoff -X-$Xoff -O -P -V -K >>plot.ps
#f3 cumulative
gmt pshistogram f3_file $bordc $proj $regc -W$w -L,0 -S -Z1 -Q -X$Xoff -O -P -V -K >> plot.ps

#f2 hist
gmt pshistogram f2_file $bordf $proj $regf -W$w -L,0 -S -Z1 -Y$Yoff -X-$Xoff -O -P -V -K >>plot.ps
#f2 cumulative
gmt pshistogram f2_file $bordc $proj $regc -W$w -L,0 -S -Z1 -Q -X$Xoff -O -P -V -K >> plot.ps

#f1 hist
gmt pshistogram f1_file $bordf $proj $regf -W$w -L,0 -S -Z1 -Y$Yoff -X-$Xoff -O -P -V -K >>plot.ps
#f1 cumulative
gmt pshistogram f1_file $bordc $proj $regc -W$w -L,0 -S -Z1 -Q -X$Xoff -O -P -V -K >> plot.ps
                                                                                

echo f4 | gmt pstext -R1/10/1/10 -JX2 -F+cTL+f18p,Helvetica -P -K -O -X-1.5i -Y-7.2i >> plot.ps
echo f3 | gmt pstext -R1/10/1/10 -JX2 -F+cTL+f18p,Helvetica -P -K -O  -Y$Yoff >> plot.ps
echo f2 | gmt pstext -R1/10/1/10 -JX2 -F+cTL+f18p,Helvetica -P -K -O  -Y$Yoff >> plot.ps
echo f1 | gmt pstext -R1/10/1/10 -JX2 -F+cTL+f18p,Helvetica -P -K -O  -Y$Yoff >> plot.ps
ps2pdf plot.ps                                                                  
evince plot.pdf



