#!/bin/bash

set -euo pipefail

if [ $(id -u) -ne 0 ]; then
    echo "Invoke the script as root!" >&2
    exit 1
fi

users=$(ps -e -o user= | sort -u)

for user in ${users}; do
    info=$(ps -u "${user}" -o pid=,rss=)
    numProcesses=$(echo "${info}" | awk '{print $1}' | sort -u | wc -l)
    rssColumn=$(echo "${info}" | awk '{print $2}')
    rssSum=0

    for rss in ${rssColumn}; do 
        rssSum=$(( $rssSum + $rss ))
    done

    printf "%-20s Active processes: %-8d Total RSS: %10d KB\n" "${user}" "${numProcesses}" "${rssSum}"

    flaggedProcess=$(echo "${info}" | sort -k2 | tail -n1)
    flaggedPid=$(echo "${flaggedProcess}" | awk '{print $1}')
    flaggedRSS=$(echo "${flaggedProcess}" | awk '{print $2}')

    if [ $(( $flaggedRSS * $numProcesses )) -ge $(( $rssSum * 2 )) ]; then
        echo "kill ${flaggedPid}"
        # kill "${flaggedPid}"; sleep 2; kill -KILL "${flaggedPid}"
    fi
done
