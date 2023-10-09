#!/bin/bash

if [[ $# -gt 0 ]]; then
    echo "The script doesnt accept arguments" >&2
    exit 1
fi

unique_numbers=()
maxAbsolute=0

while IFS= read -r line; do
    if [[ "$line" =~ ^-?[0-9]+$ ]]; then

        if [[ ! "${unique_numbers[@]}" =~ $line ]]; then
            unique_numbers+=("$line")
            absolute=$(echo "$line" | tr -d '-')

            if [[ $absolute -gt $maxAbsolute ]]; then
                maxAbsolute=$absolute
            fi 
        fi
    fi
done

for num in "${unique_numbers[@]}"; do
    absolute=$(echo "$num" | tr -d '-')
    if [[ $absolute -eq $maxAbsolute ]]; then
        echo "$num"
    fi
done