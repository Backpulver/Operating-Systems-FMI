#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "The script requires 1 username to check if the user is logged"
	exit 1
fi

while true
do
	if who | grep -q "$1"; then
		echo "The user $1 is online"
		break
	else
		echo -n "The user is ofline"
		sleep 1
		i=0
		while [[ i -lt 3 ]]; do
			echo -n "."
			sleep 1
			i=$(( i + 1 ))
		done
		echo ""
	fi
done
