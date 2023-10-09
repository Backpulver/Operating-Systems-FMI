#!/bin/bash

echo "Enter 3 files: "
read -r file1 
if [[ ! -f $file1 ]]; then
	echo "$file1 is not a file!"
	exit 1
fi

read -r file2
if [[ ! -f $file2 ]]; then
	echo "$file2 is not a file!"
	exit 2
fi

read -r file3
if [[ ! -f $file3 ]]; then
	echo "$file3 is not a file!"
	exit 3
fi

if paste "$file1" "$file2" > "$file3"; then
	echo "Success"
else
	echo "Error"
	exit 5
fi
