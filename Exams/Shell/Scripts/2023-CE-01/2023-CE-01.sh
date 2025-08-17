#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ${0} <CSV file> <Star type>" >&2
    exit 1
fi

if [ ! -f "${1}" ]; then
    echo "${1} is not a valid file" >&2
    exit 2
fi

if ! [[ $(file "${1}") =~ CSV ]]; then
    echo "${1} is not a CSV file" >&2
    exit 3
fi

filteredFile=""

while IFS= read -r line || [ -n "$line" ]; do
    type=$(echo "${line}" | cut -d',' -f5)

    if [ "$type" == "--" ]; then
        continue
    fi

    if [ "${2}" != "${type}" ]; then
        continue
    fi

    name=$(echo "${line}" | cut -d',' -f1)
    constellation=$(echo "${line}" | cut -d',' -f4)
    magnitude=$(echo "${line}" | cut -d',' -f7)

    if [ "$magnitude" == "--" ]; then
        continue
    fi

    filteredFile=$(echo -e "${filteredFile}\n${constellation},${magnitude},${name}")
done < "${1}"


filterConstellation=$(echo "${filteredFile}" | tail -n+2 | cut -d',' -f1 | sort | uniq -c | sort -n | tail -n1 | awk '{print $2}')
echo "${filteredFile}" | grep "${filterConstellation}" | sort -t',' -n -k2,2 | head -n1 | cut -d',' -f3
