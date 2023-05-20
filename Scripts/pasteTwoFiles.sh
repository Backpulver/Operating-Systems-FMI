#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "The script requires 3 files as arguments"
	exit 1
fi

if [[ -f $1 ]]; then
	echo "$1 is file, OK"
else 
	echo "$1 is not a file!"
	exit 2
fi

if [[ -f $2 ]]; then
	echo "$2 is file, OK"
else 
	echo "$2 is not a file!"
	exit 3
fi

if [[ -f $3 ]]; then
	echo "$3 is file, OK"
else 
	echo "$3 is not a file!"
	exit 4
fi

if paste $1 $2 > $3; then
	echo "Success"
else
	echo "Error"
	ecit 5
fi
