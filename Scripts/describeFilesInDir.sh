#!/bin/bash

for file in "$@"; do
    if [[ -f $file && -r $file ]]; then
        echo "$file is a readable file"
    elif [[ -d $file ]]; then
        echo -n "$file is a directory with "
        numberOfItemsInDir=$(find "$file" -mindepth 1 -maxdepth 1 | wc -l)
        echo "$numberOfItemsInDir items: "
        items=$(find "$file" -mindepth 1 -maxdepth 1 -printf "%f_%s\n" | tr ' ' '-')
        
        for item in $items; do
            bytes=$(echo "$item" | cut -d'_' -f2)

            if [[ $bytes -lt $numberOfItemsInDir ]]; then
                name=$(echo "$item" | cut -d'_' -f1)
                echo -e "\t$name"
            fi
        done
    else
        echo "$file is neither a readable fire nor directory"
    fi
done