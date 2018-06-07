#!/bin/bash

#number of stills to take
n=3
#time between stills
t=5
#no default batch name
b=""

#optional arguments
while getopts "n:t:b:" opt; do
    case "$opt" in
    n) n=$OPTARG
        ;;
    t) t=$OPTARG
        ;;
    b) b=$OPTARG
	;;
    esac
done

#take pictures
for i in `seq 1 $n`; 
do
	FNAME=$(date +"%Y-%m-%d_%H%M")"_"$b$i
	raspistill -hf -o /home/igem/iGEM_2018/capture/$FNAME.jpg
	echo "picture taken "$FNAME".jpg"

	git add /home/igem/iGEM_2018/capture/$FNAME.jpg
	git commit -m "automated upload" -q

    	sleep $t

done

#upload to github
git push -q
echo "pictures uploaded"
