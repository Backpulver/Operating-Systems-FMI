#!/bin/bash

if [[ $# -gt 2 || $# -eq 0 ]]; then
    echo "The script can accepts only 1 directory as an argument or -a flag and a directory" >&2
    exit 1
fi

if [[ $# -eq 1 ]]; then
    startDir=$1
else
    flag=$1
    startDir=$2
fi

if [[ ! -d $startDir ]]; then
    echo "The provided argument is not a directory"
    exit 2
fi

if [[ -z $flag ]]; then
    dirs=$(find "$startDir" -mindepth 1 -maxdepth 1 -type d ! -regex '.*/\..*')
    for dir in $dirs; do
        dirName=$(echo "$dir" | rev | cut -d'/' -f1 | rev)
        entries=$(find "$dir" -mindepth 1 -maxdepth 1 | wc -l)
        echo "$dirName (entries $entries)"
    done

    find "$startDir" -maxdepth 1 -type f ! -regex '.*/\..*' -printf "%f (%s bytes)\n"
    exit 0
fi

dirs=$(find "$startDir" -mindepth 1 -maxdepth 1 -type d)
for dir in $dirs; do
    dirName=$(echo "$dir" | rev | cut -d'/' -f1 | rev)
    entries=$(find "$dir" -mindepth 1 -maxdepth 1 | wc -l)
    echo "$dirName (entries $entries)"
done

find "$startDir" -maxdepth 1 -type f -printf "%f (%s bytes)\n"