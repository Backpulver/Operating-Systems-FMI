#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "The script accepts only a directory as an argument"
	exit 1
fi

if ! [[ -d $1 ]]; then
	echo "The provided argument is not a directory"
	exit 2
fi

files=$(find $1 -type f -exec sha1sum {} \; | sort | uniq -w40)
echo "$files"
