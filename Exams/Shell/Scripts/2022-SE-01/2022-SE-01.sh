#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} <Config file>" >&2
    exit 1
fi

if [ ! -f "${1}" ]; then
    echo "${1} is not a valid file" >&2
    exit 2
fi

conf=$(sed -r "s/#.*$//" "${1}")

# change to /proc/acpi/wakeup for actual solution
file=$(cat ./example-wakeup | tail -n+2 | awk '{print $1,$3}')

while IFS= read -r line; do
    device=""
    state=""
    device=$(echo "${line}" | awk '{print $1}')

    if [ -z "${device}" ]; then
        continue
    fi

    if ! echo "${device}" | grep -Eq "^[A-Z0-9]{1,4}$"; then
        echo "Warning: Device ${device} is not valid!"
        continue
    fi

    state=$(echo "${line}" | awk '{print $2}')

    if [ -z "${state}" ]; then
        continue
    fi

    if ! echo "${state}" | grep -Eq "^(enabled|disabled)$"; then
        echo "Warning: ${device} has a unknown state: ${state}!"
        continue
    fi

    if ! echo "${file}" | cut -d' ' -f1 | grep -Eq "^${device}$"; then
        echo "Warning: Device ${device} doesn't exist!"
        continue
    fi

    currectDeviceState=$(echo "${file}" | grep -E "^${device}" | cut -d' ' -f2 | cut -c2-)

    if [ "${state}" != "${currectDeviceState}" ]; then
        # change the quotes for the actual solution
        echo "${device} > /proc/acpi/wakeup"
    fi
done < <(echo "$conf")