#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <-r, -g, -b, -x>" >&2
    exit 1
fi

if [[ $1 == -r ]]; then
    color=1
elif [[ $1 == -g ]]; then
    color=2
elif [[ $1 == -b ]]; then
    color=3
elif [[ $1 == -x ]]; then
    while IFS= read -r line; do
        echo "$line"
    done
    exit 0
fi

while IFS= read -r line; do
    if [[ $color -eq 1 ]]; then
        echo -e "\033[0;31m $line"
        ((color++))
    elif [[ $color -eq 2 ]]; then
        echo -e "\033[0;32m $line"
        ((color++))
    else
        echo -e "\033[0;34m $line"
        color=1
    fi
done
echo -en '\033[0m'