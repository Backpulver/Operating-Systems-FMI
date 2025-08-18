#!/bin/bash

set -euo pipefail 

if [ "$#" -ne 1 ]; then
	echo "Usage: ${0} <directory>" 1>&2
	exit 1
fi

if [ ! -d "${1}" ]; then
	echo "${1} is not a directory" 1>&2
	exit 2
fi

symlinks=$(find "${1}" -type l  2>/dev/null)

for link in ${symlinks}; do
	if [ ! -e "${link}" ]; then
		echo "${link}"
	fi
done