#!/bin/bash

if [[ $# -gt 2 ]]; then
	echo "The script accepts only 2 arguments"
	exit 1
fi

if ! [[ $1 =~ ^-?[0-9]+$ ]]; then
	echo "The first argument needs to be an integer"
	exit 2
fi 

separator=" "
if [[ $# -eq 2 ]]; then
	separator=$2
fi

revedNum=$(echo "$1" | rev)
spaceCounter=0
niceNum=""

for (( i=0; i<${#revedNum}; i++ )); do
	niceNum+=${revedNum:i:1}
	if [[ $spaceCounter -eq 2 ]]; then
		if [[ $((i+1)) -eq ${#revedNum} ]]; then
			break
		fi
		niceNum+="$separator"
		spaceCounter=0
	else
		((spaceCounter++))
	fi
done

echo "$niceNum" | rev
