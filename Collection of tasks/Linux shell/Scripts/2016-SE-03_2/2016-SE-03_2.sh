#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: ${0} <number1> <number2>" 1>&2
	exit 1
fi

if echo "${1}" | grep -Evq '^[1-9][0-9]*|0$'; then
	echo "${1} is not a number" 1>&2
	exit 2
fi

if echo "${2}" | grep -Evq '^[1-9][0-9]*|0$'; then
	echo "${2} is not a number" 1>&2
	exit 3
fi

if ! mkdir a b c; then
	echo "Cannot create directories 'a', 'b' and 'c'" 1>&2
	exit 4
fi

while IFS= read -r line; do
	numberOfLines="$(wc -l "${line}" | cut -d" " -f1)"

	if [ "${numberOfLines}" -lt "${1}" ]; then
		if ! mv "$line" a; then
			echo "Error moving file $line" 1>&2
			exit 5
		fi
	elif [ "${numberOfLines}" -ge "${1}" ] && [ "${numberOfLines}" -le "${2}" ]; then
		if ! mv "${line}" b; then
			echo "Error moving file $line" 1>&2
			exit 6
		fi
	else
		if ! mv "$line" c; then
			echo "Error moving file $line" 1>&2
			exit 7
		fi
	fi
done < <(find . -maxdepth 1 -type f)