#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} <directory>" 1>&2
    exit 1
fi

if [ ! -d "${1}" ]; then
    echo "${1} is not a directory or does not exist" 1>&2
    exit 2
fi

if [ ! -r "${1}" ]; then
    echo "${1} is not readable" 1>&2
    exit 3
fi

info=$(mktemp)
space=0
group_count=0

files=$(find "${1}" -type f -printf "%p@%s\n" 2>/dev/null)

for file in ${files}; do
	hash=$(sha1sum $(echo "${file}" | cut -d'@' -f1) | awk -F ' ' '{print $1}')
	echo "${hash}@${file}" >> "${info}"
done

hashes=$(cat "$info" | cut -d'@' -f1 | sort | uniq)

for hash in $hashes; do
	dup_file_names=$(cat "${info}" | grep -E "^${hash}*" | cut -d'@' -f2)
	bytes=$(grep -E "^${hash}@" "${info}" | cut -d'@' -f3 | head -n1)
	source=$(echo "$dup_file_names" | head -n1)

	for dup in $dup_file_names; do
		if [ "$dup" == "$source" ]; then
			continue
		fi

		rm "$dup"
		ln "${source}" "${dup}"
	done

	group_count=$((group_count + 1))
	num_of_dups=$(echo "${dup_file_names}" | wc -l)
	helper=$((num_of_dups * bytes))
	space=$((space + helper - bytes))
done

rm "${info}"

echo "Number of groups of files: $group_count"
echo "Space freed in bytes:      $space"
