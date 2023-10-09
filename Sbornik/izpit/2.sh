#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "$1 is not a directory" >&2
    exit 2
fi

files=$(find "$1" -type f 2>/dev/null)
numOfFiles=$(find "$1" -type f 2>/dev/null | wc -l)
halfOfFiles=$(($numOfFiles/2))
allWords=()

if ! touch tmp; then
    echo "Cannot create file tmp" >&2
    exit 3
fi

for file in $files; do
    echo "$file"
    fileWords=()
    while IFS= read -r line; do
        # echo "Line: $line"
        wordsNum=$(echo "$line" | wc -w)
        echo "Number of words $wordsNum"

        for((i=1; i<=$wordsNum; i++)); do
            # echo "$i"
            word=$(echo "$line" | cut -d' ' -f$i)
            echo "$word"
            if [[ ! $fileWords =~ $word ]]; then
                fileWords+=($word)
            fi
        done
    # echo "The uniq words are"
    # echo "$fileWords"
    done < "$file"
done 