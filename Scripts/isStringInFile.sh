#!/bin/bash

echo "Enter a file name"
read -r file
if [[ ! -f $file ]]; then
	echo "This is not a file"
	exit 1
fi

echo "Enter a string to search for in the file"
read -r string

egrep -q $string $file
status=$?

if [[ $status -eq 0 ]]; then
	echo "The string is in the file, exited with status code $status"
else
	echo "The string in not in the file. exited with status code $status"
	exit 2
fi
