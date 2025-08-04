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

numbers=$(echo "${numbers}" | cut -c2- | tr ' ' '\n' | uniq | sort -n)
answerList=""

while IFS= read -r num; do
    digits=$(echo "$num" | tr -d '-' | fold -w1)
    sum=0

    for digit in ${digits}; do
        (( sum += digit ))
    done

    answerList=$(echo -e "${answerList}\n${num}@${sum}")
done < <(echo "$numbers")

echo "${answerList}" | tail -n+2 | sort -t '@' -k2,2r -k1,1n | head -n1 | cut -d'@' -f1
