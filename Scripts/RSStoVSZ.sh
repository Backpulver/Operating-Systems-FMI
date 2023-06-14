#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <username>" >&2
    exit 1
fi

user_id=$(id -u "$1" 2>/dev/null)

if [[ -z "$user_id" ]]; then
    echo "User $1 not found" >&2
    exit 2
fi

processes=$(ps -u "$1" -o pid,rss,vsz --no-headers | tr -s ' ' | sort -nr -k3 | sed s/^\ //)

while IFS= read -r line; do
    pid=$(echo "$line" | cut -d' ' -f1)
    rss=$(echo "$line" | cut -d' ' -f2)
    vsz=$(echo "$line" | cut -d' ' -f3)
    echo -n "$pid " 
    echo "scale=2; $rss/$vsz" | bc
done <<< "$processes"