#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bad_words_file> <directory>" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "$1 is not a valid file" >&2
    exit 2
fi

if [ ! -d "$2" ]; then
    echo "$2 is not a valid directory" >&2
    exit 3
fi

words=()

while read -r line; do
    all=$(find "${2}" -type f -name "*.txt" -exec grep -iow "${line}" {} \; 2>/dev/null | grep -x "[A-Za-z0-9_]+")

    for word in ${all}; do
        words+=("$word")  
    done
done < "$1"

words=($(echo "${words[@]}" | tr ' ' '\n' | sort | uniq | tr '\n' ' '))

for word in "${words[@]}"; do
    censor=$(echo "$word" | sed -e s/./\*/g)
    
    find "${2}" -type f -name "*.txt" -exec sed -i "s/\<${word}\>/${censor}/g" {} \; 2>/dev/null
done