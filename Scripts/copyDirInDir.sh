#!/bin/bash

if [[ $# -eq 0 || $# -gt 2 ]]; then
	echo "The script can accept 1 or 2 directories as parameters"
	exit 1
fi

if [[ ! -d $1 ]]; then
	echo "$1 is not a directory"
	exit 1
fi

if [[ $# -eq 2 && ! -d $2 ]]; then
	echo "$2 is not a directory"
	exit 2
fi

if [[ $# -eq 2 ]]; then
	if find $1 -mindepth 1 -mmin -45 -exec cp -r {} $2 \;; then
		echo "Copy of files modified in the last 45mins successful"
	else
		echo "Error when copying"
		exit 3
	fi
	dir2=$2
else
	dateTime=$(date +%Y-%m-%d)
	if mkdir $dateTime; then
		echo "Creating new dir successful"
	else
		echo "Directory with this date and time already exists"
		exit 4
	fi

	if find $1 -mindepth 1 -mmin -45 -exec cp -r {} $dateTime \;; then
		echo "Copy of files modified in the last 45mins successful"
	else
		echo "Error when copying"
		exit 5
	fi
	dir2=$dateTime
fi

echo -n "Do you want to archive the directory with the copied files [y/n]: "
read -r  yno

if [[ $yno == "y" ]]; then
	if tar -czf "$dir2.tgz" "$dir2"; then
		echo "Creating of archive successful"
	else
		echo "Error when creating archive"
		exit 6
	fi
fi
