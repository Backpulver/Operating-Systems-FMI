#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "The script accepts a file and a directory as arguments"
	exit 1
fi

if [[ ! -f $1 ]]; then
	echo "The first argument is not a file"
	exit 2
fi

if [[ ! -d $2 ]]; then
	echo "The second argument is not a directory"
	exit 3
fi

shaFile=$(sha1sum "$1" | cut -d' ' -f1)
find "$2" -mindepth 1 -type f -exec sha1sum {} \; | grep "$shaFile" | tr -s ' ' | cut -d' ' -f2
