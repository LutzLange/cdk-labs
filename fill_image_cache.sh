#!/bin/bash
#
# This needs to run as root or get access to the docker deamon
#    configure sudo to get this right
#
BASE="/home/llange/.minishift/cache/images"
mkdir -p $BASE

for IMG in $(cat *-images.txt) 
do
	TNAME=$(echo $IMG | sed 's/\//@/g' | sed 's/:/@/')
	# next line should have a sudo at the beginning
        docker save $IMG > "$BASE/$TNAME"
done
