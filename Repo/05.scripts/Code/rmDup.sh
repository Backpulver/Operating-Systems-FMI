#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "The script accepts only a directory as an argument"
	exit 1
fi

if [[ ! -d $1 ]]; then
	echo "The provided argument is not a directory"
	exit 2
fi

fileOrder=$(find "$1" -maxdepth 1 -type f | sort)

for file in $fileOrder; do
	if [[ ! -f $file ]]; then
		continue
	fi
	currHash=$(sha1sum "$file" | tr -s ' ' | cut -d' ' -f1)
	filesRM=$(find "$1" -maxdepth 1 -type f -not -regex "$file" -exec sha1sum {} \; | grep "$currHash" | tr -s ' ' | cut -d' ' -f2)
	
	if [[ $filesRM != "" ]]; then
		if ! echo "$filesRM" | xargs rm; then
			echo "Error when deleting"
			exit 3
		fi
	fi
done