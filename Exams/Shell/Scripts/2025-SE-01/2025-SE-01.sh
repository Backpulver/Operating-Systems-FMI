#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: ${0} <config file> <input file>" >&2
    exit 1
fi

if [ ! -f "${1}" ]; then
    echo "${1} is not a file or doesnt exist" >&2
    exit 2
fi

if [ ! -f "${2}" ]; then
    echo "${2} is not a file or doesnt exist" >&2
    exit 3
fi

baseInputFile=$(basename "${2}" | cut -d'.' -f1)

while read -r line; do
    if ! echo "$line" | grep -qEo ".+ (.+ ){0,}'(/[^/]+)+/?'"; then
        continue
    fi

    language=$(echo "$line" | cut -d' ' -f1)
    baseOutputDir=$(echo "$line" | rev | cut -d"'" -f2 | rev)
    lastChar=$(echo -n "${baseOutputDir}" | tail -c1)
    
    if [ "${lastChar}" == '/' ]; then
        outputDir="${baseOutputDir}${baseInputFile}"
    else
        outputDir="${baseOutputDir}/${baseInputFile}"
    fi

    options=""
    optionsList=$(echo "$line" | cut -d' ' -f2- | rev | cut -d"'" -f3- | rev | tr ' ' '\n' | sort -u | tr '\n' ' ')

    if ! echo "${optionsList}" | grep -qEo "\<listener\>"; then
        options="${options} -no-listener"
    fi

    if echo "${optionsList}" | grep -qEo "\<visitor\>"; then
        options="${options} -visitor"
    fi

    cmd="antlr4 -Dlanguage=${language}${options} -o ${outputDir} ${2}"
    echo "$cmd"
    # exec "$cmd"
done < "${1}"
