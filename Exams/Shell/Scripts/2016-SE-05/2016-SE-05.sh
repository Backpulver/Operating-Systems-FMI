#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <$HOME/file1> <$HOME/file2>" >&2
	exit 1
fi

file1=$(echo "$HOME/${1}")
file2=$(echo "$HOME/${2}")

if [ ! -f "$file1" ]; then
	echo "${file1} is not a file or does not exist" >&2
	exit 2
fi

if [ ! -f "$file2" ]; then
	echo "${file2} is not a file or does not exist" >&2
	exit 3
fi

count1=0
count2=0

set +e
while read line; do
	if echo "${line}" | grep -q "${1}"; then
		((count1++))
	fi
done < "${file1}"

while read line; do
	if echo "${line}" | grep -q "${2}"; then
		((count2++))
	fi
done < "${file2}"

set -e
winner="${file1}"
outputFile="${1}.songs"

if [ "${count1}" -lt "${count2}" ]; then
	winner="${file2}"
	outputFile="${2}.songs"
fi

echo -n > "${outputFile}"
basename=$(basename "${winner}")

while read line; do
	if echo "${line}" | grep -Eq "^[0-9]{4}г\. ${basename}"; then
		echo "${line}" | cut -d' ' -f4- >> "${outputFile}"
	fi
done < "${winner}"

sort "${outputFile}" -o "${outputFile}"
