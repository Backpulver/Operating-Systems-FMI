#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 number1 number2"
	exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ && $2 =~ ^[0-9]+$ ]]; then
	echo "The parameters are not numbers!"
	exit 2
fi

if ! mkdir a b c; then
	echo "Cannot create directories 'a', 'b' and 'c'"
	exit 3
fi

find . -maxdepth 1 -type f | while IFS= read -r line; do
	numberOfLines=$(wc -l "$line" | cut -d" " -f1)

	if [[ $numberOfLines -lt $1 ]]; then
		if ! mv "$line" a; then
			echo "Error moving file $line"
			exit 4
		fi
	elif [[ $numberOfLines -ge $1 && $numberOfLines -le $2 ]]; then
		if ! mv "$line" b; then
			echo "Error moving file $line"
			exit 5
		fi
	else
		if ! mv "$line" c; then
			echo "Error moving file $line"
			exit 4
		fi
	fi
done