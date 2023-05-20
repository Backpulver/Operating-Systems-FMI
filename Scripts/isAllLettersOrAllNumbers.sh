#!/bin/bash

if [[ $# -ne 1 ]] then
	echo "The script accepts only one parameter"
	exit 1
fi

if [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Only numbers"
elif [[ $1 =~ ^[a-zA-Z]+$ ]]; then
    echo "Only letters"
else
    echo "Not only numbers nor letters"
fi
