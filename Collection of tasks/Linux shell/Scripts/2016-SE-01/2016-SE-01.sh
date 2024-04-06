#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

if [ ! -d "$1" ]; then
	echo "$1 is not a directory"
	exit 2
fi

find "$1" -type l -not -exec test -e {} \; -print 2>/dev/null