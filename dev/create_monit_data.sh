#!/bin/bash

rses=("XRD1" "XRD2" "XRD3")

lifetime=300

count=1

while :
do
    i=1
    for srcrse in ${rses[@]}; do
        filename=file${i}_$(uuidgen)
        ((i++))
        bs=$((1 + RANDOM % 10000))
        dd if=/dev/urandom of=$filename bs=$bs count=$count
        rucio upload --rse $srcrse --scope test $filename
        sleep 10
        rm $filename
        for dstrse in ${rses[@]}; do
            if [ $srcrse = $dstrse ]; then continue; fi
            rucio add-rule --activity 'User Subscriptions' --lifetime $lifetime --source-replica-expression $srcrse test:$filename 1 $dstrse
            sleep 10
        done
    done
done
