#!/bin/bash

for file in "$@"; do
    if [[ ! -f $file ]]; then
        echo "$file is not a file" >&2
        exit 1
    fi
done

echo -n "Enter a string for searching in the files: "
read -r string

for file in "$@"; do
    echo "In $file \"$string\" is contained on $(grep "$string" "$file" | wc -l) lines"
done