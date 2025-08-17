#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} <file>" >&2
    exit 1
fi

if [ ! -f "${1}" ]; then
    echo "${1} is not a valid file" >&2
    exit 2
fi

cut -d'-' -f2- "${1}" | nl -w1 -s'.' | sed -r "s/(.*„([^“]+)“.*)/\2@\1/" | sort -t'@' -k1,1 | cut -d'@' -f2-
