#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "The script accepts 1 username as a parameter" >&2
    exit 1
fi

pids=$(ps -u "$1" -o pid --no-headers)
processCount=0

echo "$pids"
for pid in $pids; do
    if kill "$pid"; then
        ((processCount++))
    else
        echo "Couldn't kill the processes with pid: $pid" >&2
    fi 
done
echo "Killed $processCount processes for user $1"