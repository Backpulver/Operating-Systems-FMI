#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage ${0} <RSS limit>" 1>&2
    exit 2
fi

if echo "${1}" | grep -Evq "^[1-9][0-9]*|0$"; then
    echo "${1} is not a number" 1>&2
    exit 3
fi

while IFS= read -r uid; do
    total_RSS=0

    while IFS= read -r rss; do
        total_RSS=$((total_RSS + rss))
    done < <(ps -eo uid,rss --no-headers | tr -s ' ' | grep "^ ${uid}" | cut -d' ' -f3)

    echo "User ${uid} has: ${total_RSS}"

    if [ "${total_RSS}" -gt "${1}" ]; then
        highest_rss_pid=$(ps -eo uid,pid,rss --no-headers | tr -s ' ' | grep "^ ${uid}" | sort -n -k3 | tail -n1 | cut -d' ' -f3)
        echo "Terminating process $highest_rss_pid of user $uid"
        # kill "${highest_rss_pid}"
    fi
done < <(ps -eo uid --no-headers | sort -u | tr -s ' ' | cut -c2-)