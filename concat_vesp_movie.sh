#!/bin/bash

for d in Event*/SUB*; do
    if [ -e $d/CLEAN ]; then 
       event=$(echo $d | awk -F"/" '{print $1}')
       array=$(echo $d | awk -F"/" '{print $2}')
       name=${event}_${array:(-2)}.pdf
       echo "$d/CLEAN found, creating pdf"
       (cd $d && convert vespagram/*ps $name)
    else
       echo "$d/CLEAN not found"
    fi
done
