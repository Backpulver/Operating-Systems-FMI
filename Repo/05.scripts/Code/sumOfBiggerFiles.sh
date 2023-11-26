#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <directory> <integer>" >&2
    exit 1
fi

if [[ ! -d $1 ]]; then
    echo "$1 is not a directory" >&2
    exit 2
fi

if [[ ! $2 =~ ^[0-9]+$ ]]; then
    echo "$2 is not an integer" >&2
    exit 3
fi

files=$(find "$1" -mindepth 1 -type f -printf "%f_%s\n" 2>/dev/null | tr ' ' '-')
sum=0

for file in $files; do
    size=$(echo "$file" | cut -d'_' -f2)

    if [[ $size -gt $2 ]]; then
        ((sum+=size))
    fi
done
echo "The sum of the bytes in files that are bigger than $2 bytes is: $sum"