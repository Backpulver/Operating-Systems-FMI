#!/bin/bash

set -euo pipefail
user=""

if [ $(whoami) == "oracle" ]; then
	user="oracle"
elif [ $(whoami) == "grid" ]; then
	user="grid"
else
	echo "Wrong user" >&2
	exit 1
fi

if [ -z "${ORACLE_HOME}" ]; then
	echo "ORACLE_HOME variable is not set" >&2
	exit 2
fi

if echo "${ORACLE_HOME}" | grep -eq "^/([^/]+/)*[^/]*$"; then
	echo "ORACLE_HOME variable is not an absolute path" >&2
	exit 3
fi

if [ ! -d "${ORACLE_HOME}" ]; then
	echo "ORACLE_HOME is not a direcotry or cannot be accessed" >&2
	exit 4
fi 

if [ ! -f "${ORACLE_HOME}/bin/adrci" ];then
	echo "${ORACLE_HOME}/bin/adrci is not a file or cannot be accessed" >&2
	exit 5
fi

if [ ! -x "${ORACLE_HOME}/bin/adrci" ];then
	echo "${ORACLE_HOME}/bin/adrci cannot be executed" >&2
	exit 6
fi

diag_dest=$(echo "/u01/app/${user}")

if [ ! -d "${diag_dest}" ]; then
	echo "${diag_dest} is not a direcotry or cannot be accessed" >&2
	exit 7
fi

command="${ORACLE_HOME}/bin/adrci exec=\"show homes\""
output=$(eval "${command}")

if echo "$output" | grep -q '^No ADR homes are set'; then
	exit 0
fi

while read -r line; do
	path=$(realpath -e "${diag_dest}/${line}")
	du -sb "${path}"  2>/dev/null
done < <(echo "${output}" | tail -n+2)

