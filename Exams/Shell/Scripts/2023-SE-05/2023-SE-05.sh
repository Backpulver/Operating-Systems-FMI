#!/bin/bash

set -euo pipefail

info=()
id=0

while true; do
    snapshot=$(ps -eo pid,rss,comm  --no-headers)
    names=$(echo "${snapshot}" | awk -F ' ' '{print $3}' | sort | uniq)
    size_info=$(echo "${#info[@]}")

    for name in ${names}; do
        rss_sum=$(echo "${snapshot}" | grep -F "${name}" | awk '{sum+=$2} END {print sum}')

        if [ "$rss_sum" -gt 65535 ]; then
            info+=("${name}@${rss_sum}")
        fi
    done

    size_info_aft=$(echo "${#info[@]}")

    if [ "${size_info}" -eq "${size_info_aft}" ]; then
        break
    fi

    ((id++))
    sleep 1
done

comms=$(echo "${info[@]}" | tr ' ' '\n' | cut -d'@' -f1 | sort | uniq)
id=$((id / 2))

for comm in ${comms}; do
    appears=$(echo "${info[@]}" | tr ' ' '\n' | grep -F -c "${comm}")

    if [ "$appears" -ge "$id" ]; then
        echo "$comm"
    fi
done