#!/bin/bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
	echo "Usage: ${0} <Data file 1> <Data file 2> <Black hole name>"  >&2
	exit 1
fi

if [ ! -f "${1}" ]; then
	echo "${1} is not a valid file" >&2
	exit 2
fi

if [ ! -f "${2}" ]; then
	echo "${2} is not a valid file" >&2
	exit 3
fi

distance1=$(grep -Eo "^.+: (0|[1-9][0-9]*) megaparsecs$" "${1}" | grep "^${3}:" | cut -d':' -f2 | cut -d' ' -f2 || true)
distance2=$(grep -Eo "^.+: (0|[1-9][0-9]*) megaparsecs$" "${2}" | grep "^${3}:" | cut -d':' -f2 | cut -d' ' -f2 || true)

answerFile=""

if [ -z "${distance1}" ] && [ -z "${distance2}" ]; then
	echo "No point contain the name of the black hole" >&2
	exit 4
elif [ -z "${distance1}" ]; then
	answerFile="${2}"
elif [ -z "${distance2}" ]; then
	answerFile="${1}"
elif [ "${distance1}" -le "${distance2}" ]; then
	answerFile="${1}"
else
	answerFile="${2}"
fi

basename "${answerFile}"
