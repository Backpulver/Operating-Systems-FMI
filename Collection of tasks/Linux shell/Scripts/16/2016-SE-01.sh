#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <directory>" >&2
	exit 1
fi

if [[ ! -d "$1" ]]; then
	echo "$1 is not a directory" >&2
	exit 2
fi

find "$1" -type l -xtype l 2>/dev/null