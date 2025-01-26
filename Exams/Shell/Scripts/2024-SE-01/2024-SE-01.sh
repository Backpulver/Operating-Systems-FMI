#!/bin/bash

set -euo pipefail

files=($(echo "${@}" | tr ' ' '\n' | grep -Ev "^\-"))
replaces=($(echo "${@}" | tr ' ' '\n' | grep -Eo "^\-[A-Za-z0-9]+=[A-Za-z0-9]+$" | cut -c 3-))
uniq_replaces=()

if [[ "${#files[@]}" -eq 0 || "${#replaces[@]}" -eq 0 ]]; then
    echo "Usage: $0 -Rword1=word2 file1 file2 ..."
    exit 1
fi

for replace in "${replaces[@]}"; do
    word1=$(echo "${replace}" | cut -d'=' -f1)
    word2=$(echo "${replace}" | cut -d'=' -f2)
    uniq_word=$(pwgen 20 1)

    for file in "${files[@]}"; do
        tmp=$(mktemp)

        while IFS= read -r line; do
            if [[ "$line" =~ ^# ]]; then
                echo "$line" >> "$tmp"
            else
                replaced_line=$(echo "$line" | sed "s/\<${word1}\>/${uniq_word}/g")
                echo "$replaced_line" >> "$tmp"
            fi
        done < "$file"
        
        cat "$tmp" > "$file"
        rm "$tmp"
    done

    uniq_replaces+=("${uniq_word}=${word2}")
done

for replace in "${uniq_replaces[@]}"; do
    word1=$(echo "${replace}" | cut -d'=' -f1)
    word2=$(echo "${replace}" | cut -d'=' -f2)

    for file in "${files[@]}"; do
        sed -i "s/\<${word1}\>/${word2}/g" "${file}"
    done
done
