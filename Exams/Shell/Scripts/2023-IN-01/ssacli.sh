#!/bin/bash

set -euo pipefail

if [ $(id -u) -ne 0 ]; then
    echo "Not root"
    exit 1
fi

if echo "$*" | grep -Pq "^ctrl slot=\d+ pd all show detail$"; then
    num=$(echo "$*" | grep -Po "\d+")
    file="./data${num}.txt"

    if find . -type f -regex "${file}" &> /dev/null; then
        cat "${file}"
    fi
fi
