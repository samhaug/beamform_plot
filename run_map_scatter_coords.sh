#!/bin/bash

for d in Event_201*/SUB*; do 
    if [ -e $d/CLEAN ]; then 
        echo $d
        (cd ${d}/scatter && ~/src/beamform_plot/map_scatter_coords.sh PP_locations.dat SP_locations.dat ../describe ); 
    fi; 
done

