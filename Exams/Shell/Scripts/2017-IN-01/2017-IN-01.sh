#!/bin/bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
	echo "Usage: ${0} <name_of_file> <string1> <string2>" 1>&2
	exit 1
fi 

if ! [ -f "${1}" ]; then
	echo "File ${1} does not exist or is not a file" 1>&2
	exit 2
fi 

if ! [ -r "${1}" ]; then
	echo "File ${1} is not readable" 1>&2
	exit 3
fi

key2=$(cat "${1}" | grep -E "${3}=(.*? )*" | cut -d'=' -f1)

uniqTerms1=$(cat "${1}" | grep -E "${2}=(.*? )*" | cut -d'=' -f2 | tr ' ' '\n' | sort | uniq)
uniqTerms2=$(cat "${1}" | grep -E "${3}=(.*? )*" | cut -d'=' -f2 | tr ' ' '\n' | sort | uniq)

if [ -z "${key2}" ] || [ -z "${uniqTerms1}" ]; then
	exit 0
fi

while IFS= read -r line; do
	uniqTerms2=$(echo "${uniqTerms2}" | grep -v "^${line}$")
done < <(echo "${uniqTerms1}")

replaceWith=$(echo "${uniqTerms2}" | tr '\n' ' ' | sed s/^\ //)
sed -ri "s/^(${3})=(.*\ )*.*$/\1=${replaceWith}/" "${1}"
