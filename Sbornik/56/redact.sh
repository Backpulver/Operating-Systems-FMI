#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <file> <directory for editing>" >&2
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "$1 is not a file" >&2
    exit 2
fi

if [[ ! -d $2 ]]; then
    echo "$2 is not a directory" >&2
    exit 3
fi

files=$(find "$2" -mindepth 1 -type f -name "*.txt" 2>/dev/null)

while IFS= read -r file; do
    echo "$file"

    while IFS= read -r word; do
        replace=$(grep -ow "$word" "$file" | sed -e s/./\*/g)
        sed -ie s/"$word"/"$replace"/g "$file"
    done < "$1"
done <<< "$files"