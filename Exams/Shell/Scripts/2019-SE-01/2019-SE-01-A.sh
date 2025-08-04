#!/bin/bash

set -euo pipefail

if [ "$#" -gt 0 ]; then
    echo "The script doesnt accept arguments" >&2
    exit 1
fi

numbers=""

while IFS= read -r line; do
    if [[ "$line" =~ ^-?[0-9]+$ ]]; then
        numbers="${numbers} ${line}"
    fi
done

numbers=$(echo "${numbers}" | cut -c2- | tr ' ' '\n' | uniq | sort -n | tr '\n' ' ')
maxAbsolute=0

for num in ${numbers}; do
    absolute=$(echo "$num" | tr -d '-')

    if [ "$absolute" -gt "$maxAbsolute" ]; then
        maxAbsolute=$absolute
    fi 
done

for num in ${numbers}; do
    absolute=$(echo "$num" | tr -d '-')
    if [[ $absolute -eq $maxAbsolute ]]; then
        echo "$num"
    fi
done
