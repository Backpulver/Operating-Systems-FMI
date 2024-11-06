#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: ${0} <directory>" 1>&2
	exit 1
fi

if ! [ -d "${1}" ]; then
	echo "${1} is not a directory or does not exist" 1>&2
	exit 2
fi

if ! [ -r "${1}" ]; then
	echo "${1} is not readable" 1>&2
	exit 3
fi

find "${1}" -exec sha1sum {} \; 2>/dev/null
