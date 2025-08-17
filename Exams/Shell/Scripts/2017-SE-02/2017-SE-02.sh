#!/bin/bash

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Invoke as root" >&2
    exit 1
fi

if [ "$#" -ne 3 ]; then
    echo "Usage: ${0} <Source dir> <Destination dir> <String>" >&2
    exit 2
fi

if [ ! -d "${1}" ]; then
    echo "${1} is not a valid direcotry" >&2
    exit 3
fi

if [ ! -d "${2}" ]; then
    echo "${2} is not a valid direcotry" >&2
    exit 4
fi

destItems=$(find "${2}" -mindepth 1 -maxdepth 1 | wc -l)

if [ "${destItems}" -ne 0 ]; then
    echo "${2} is not empty" >&2
    exit 5
fi

files=$(find "${1}" -type f 2>/dev/null)

src=$(realpath "${1}")
dest=$(realpath "${2}")

for file in ${files}; do
    name=$(basename "${file}")
    file=$(realpath "${file}")
    
    if echo "${name}" | grep -q "${3}"; then
        strippedPath=$(echo "$file" | sed -r "s|${src}||")
        dirsToCreate=$(dirname "${strippedPath}")
        mkdir -p "${dest}${dirsToCreate}"

        mv "${file}" "${dest}${strippedPath}"
    fi 
done
