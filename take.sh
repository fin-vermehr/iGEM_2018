#!/bin/bash

n=3
t=5



while getopts "n:t:" opt; do
    case "$opt" in
    n) n=$OPTARG
        ;;
    t) t=$OPTARG
        ;;
    esac
done


for i in `seq 1 $n`; 
do
	DATE=$(date +"%Y-%m-%d_%H%M")"_"$i
	raspistill -hf -o /home/igem/Desktop/capture/$DATE.jpg

#	git add /home/igem/Desktop/capture/$DATE.jpg
#	git commit -m "automated upload"
#	git push

    sleep $t

done

