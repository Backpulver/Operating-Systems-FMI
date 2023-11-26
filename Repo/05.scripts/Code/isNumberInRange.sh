#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "The scipt accepts 3 numbers as arguments"
	exit 10
fi

if ! [[ $1 =~ ^-?[0-9]+$ && $2 =~ ^-?[0-9]+$ && $3 =~ ^-?[0-9]+$ ]]; then
 	echo "One of the arguments is not an integer"
 	exit 3
elif [[ $1 -gt $2 && $1 -lt $3 ]]; then
	echo "The number is in the given range"
	exit 0
elif  [[ $1 -gt $3 && $1 -lt $2 ]]; then
	echo "The number has swapped bounds"
	exit 2
else
	echo "The number is not in the range"
	exit 1
fi
