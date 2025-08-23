#!/bin/bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: ${0} <number> <prefix symbol> <unit symbol>" >&2
    exit 1
fi

if [ ! -r ./prefix.csv ]; then
    echo "File prefix.csv not found or not readable" >&2
    exit 2
fi

if [ ! -r ./base.csv ]; then
    echo "File base.csv not found or not readable" >&2
    exit 3
fi

if ! file ./prefix.csv | grep -q "CSV text"; then
    echo "File prefix.csv is not a CSV text file" >&2
    exit 4
fi

if ! file ./base.csv | grep -q "CSV text"; then
    echo "File base.csv is not a CSV text file" >&2
    exit 5
fi

prefixCsv=$(tail -n+2 ./prefix.csv)
baseCsv=$(tail -n+2 ./base.csv)

outputNumber=""
outputDescription=""

while IFS= read -r line; do
    prefixSymbol=$(echo "${line}" | cut -d',' -f2)

    if [ "${prefixSymbol}" == "${2}" ]; then
        prefixNum=$(echo "${line}" | cut -d',' -f3)
        outputNumber=$(echo "${1} * ${prefixNum}" | bc)
        break
    fi
done < <(echo "${prefixCsv}")

if [ -z "${outputNumber}" ]; then
    exit 0
fi

while IFS= read -r line; do
    unitSymbol=$(echo "${line}" | cut -d',' -f2)

    if [ "${unitSymbol}" == "${3}" ]; then
        unitName=$(echo "${line}" | cut -d',' -f1)
        unitMeasure=$(echo "${line}" | cut -d',' -f3)
        outputDescription="(${unitMeasure}, ${unitName})"
        break
    fi
done < <(echo "${baseCsv}")

if [ -n "${outputDescription}" ]; then
    echo "${outputNumber} ${3} ${outputDescription}"
fi
