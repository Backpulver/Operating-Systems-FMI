#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "The script accepts 2 arguments a directory and a number" >&2
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

files=$(find "$1" -maxdepth 1 -type f -printf "%f_%s\n" | tr ' ' '-')
for file in $files; do
    number=$(echo "$file" | cut -d'_' -f2)
    if [[ $number -gt $2 ]]; then
        echo "$file" | cut -d'_' -f1
    fi
done