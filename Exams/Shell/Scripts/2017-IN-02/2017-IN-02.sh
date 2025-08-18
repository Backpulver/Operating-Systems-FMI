#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
	echo "Usage: ${0} <username>"
	exit 1
fi

if [ $(id -u) -ne 0 ]; then
	echo "The script should run as root!"
	exit 2
fi

if id -u "${1}" &>/dev/null; then 
	processesFOO=$(ps -u "${1}" -o pid= | wc -l)
else
	processesFOO=0
fi

allUsers=$(ps -eo user= | sort -u)

for user in $allUsers; do
	processesUser=$(ps -u "${user}" -o pid= | wc -l)
	if [ "$processesUser" -gt "$processesFOO" ]; then
		echo "${user}"
	fi
done

times=$(ps -eo time=)
totalSeconds=0
count=0

for time in $times; do
	h=$(echo "$time" | cut -d':' -f1)
	m=$(echo "$time" | cut -d':' -f2)
	s=$(echo "$time" | cut -d':' -f3)
	seconds=$((10#$h * 3600 + 10#$m * 60 + 10#$s))
	totalSeconds=$((totalSeconds + seconds))
	count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
    echo "No active processes, WTF!?"
	exit 3
fi

average=$((totalSeconds / count))
echo "$average"

processesFoo=$(ps -u "${1}" -o pid=,time=)

while read line; do
	time=$(echo $line | awk '{print $2}')
	pid=$(echo $line | awk '{print $1}')
	h=$(echo "$time" | cut -d':' -f1)
	m=$(echo "$time" | cut -d':' -f2)
	s=$(echo "$time" | cut -d':' -f3)
	seconds=$((10#$h * 3600 + 10#$m * 60 + 10#$s))

	if [ $seconds -gt $average ]; then
		kill "$pid"; sleep 2; kill -KILL "$pid"
	fi	
done <<< "$processesFoo"
