#!/bin/bash

set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: ${0} <Device name>" >&2
    exit 1
fi

if ! echo "${1}" | grep -Eq "^[A-Z0-9]{1,4}$"; then
    echo "${1} must contain up to four A-Z capital letters and digits" >&2
    exit 2
fi

# change to /proc/acpi/wakeup for actual solution
file=$(cat ./example-wakeup | tail -n+2)

while IFS= read -r line; do
    if ! echo "${line}" | grep -Pq "^\s*[A-Z0-9]{1,4}\s+[^ ]+\s+\*(enabled|disabled)\s+[^ ]+\s*$"; then
        continue
    fi

    device=$(echo "${line}" | awk '{print $1}')
    state=$(echo "${line}" | awk '{print $3}'| cut -c2-)

    if [ "${device}" != "${1}" ]; then
        continue
    fi

    if [ "${state}" == "enabled" ]; then
        # change the quotes for the actual solution
        echo "${device} > /proc/acpi/wakeup"
    fi
    
    exit 0
done < <(echo "${file}")