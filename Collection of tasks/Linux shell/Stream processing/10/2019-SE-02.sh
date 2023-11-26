#!/bin/bash

infos=$(grep /home/SI passwd.txt| cut -d':' -f1,5,6 | tr -s ' ' | tr -d ' ')

for info in $infos; do
    dir=$(cut -d':' -f3 "$info")
    time=$(stat -c "%Y-%n" "$dir")
    if [[ $time -gt 151168000 && $time -lt 1551176100 ]]; then
        cut -d':' -f1,2 "$info" tr ':' '\t'
    fi
done