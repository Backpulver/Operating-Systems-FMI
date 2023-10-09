#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <SOURCE DIRECTORY> <DESTINATION DIRECTORY>" >&2
    exit 1
fi

if [[ ! -d $1 ]]; then
    echo "$1 is not a directory" >&2
    exit 2
fi

if [[ ! -d $2 ]]; then
    echo "$2 is not a directory" >&2
    exit 3
fi

if ! [[ -r $2 && -w $2 && -x $2 ]]; then
    echo "Cannot access $2 directory"
    exit 4
fi

files=$(find "$1" -mindepth 1 -type f -printf "%f\n" 2>/dev/null | grep -oE '\..{,4}$' | sort | uniq)

if ! echo "$files" | xargs -I {} mkdir "$2/"{}; then
    exit 5
fi

extensions=$(find "$2" -mindepth 1 -type d -printf "%f\n")
for extension in $extensions; do
    if ! find "$1" -mindepth 1 -type f -regex ".*$extension$" -exec cp {} "$2/$extension" \; 2>/dev/null; then
        echo "Error when coping" >&2
        exit 6
    fi
done