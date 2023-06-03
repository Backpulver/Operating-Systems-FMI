#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "The scripts requires 1 C file"
	exit 1
fi

if file $1 | egrep -q "C source"; then
	echo "File is in the correct format, OK"
else
	echo "The provided argument is not a C file"
	exit 2
fi

str=$(cat $1 | tr -d "\n")
currCount=0
maxCount=0

for (( i=0; i<${#str}; i++ )); do
	if [[ ${str:$i:1} == "{" ]]; then
		((currCount++))
		if [[ $currCount -gt $maxCount ]]; then
			maxCount=$currCount
		fi
	elif [[ ${str:$i:1} == "}" ]]; then
		((currCount--))
	fi
done

echo "The deepest nesting is $maxCount levels"
