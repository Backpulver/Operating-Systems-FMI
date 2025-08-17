#!/bin/bash

set -euo pipefail

if [[ "$#" -lt 1 || "$#" -gt 2 ]]; then
    echo "Usage: ${0} <Direcotry> [Output file]" >&2
    exit 1
fi

if [ ! -d "${1}" ]; then
    echo "${1} is not a valid direcotry" >&2
    exit 2
fi

output="/dev/stdout"

if [ "$#" -eq 2 ]; then
    if [ ! -f "${2}" ]; then
        echo "${2} is not a valid file" >&2
        exit 3
    fi

    output="${2}"
fi

files=$(find "${1}" -type l 2>/dev/null)
brokenNum=0

for file in ${files}; do
    if [ -e "${file}" ]; then
        echo "$(basename "${file}") -> $(readlink "${file}")" >> "${output}"
    else
        brokenNum=$((brokenNum + 1))
    fi
done

echo "Broken symlinks: ${brokenNum}" >> "${output}"
