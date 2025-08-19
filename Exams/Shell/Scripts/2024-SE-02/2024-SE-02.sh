#!/bin/bash

set -euo pipefail

occ="$(dirname "${0}")/occ"
passwd="/etc/passwd"

if printenv PASSWD &>/dev/null; then
    if [ -n "${PASSWD}" ]; then
        passwd="${PASSWD}"
    fi
fi

passwdUsers=""
occUsername=$("${occ}" user:list | cut -d':' -f1)

while IFS= read -r line; do
    uid=$(echo "${line}" | cut -d':' -f3)
    username=$(echo "${line}" | cut -d':' -f1)

    if [ "${uid}" -lt 1000 ]; then
        continue
    else
        passwdUsers=$(echo -e "${passwdUsers}\n${username}")
    fi
    
    if ! echo "${occUsername}" | grep -q "^- ${username}$"; then
        "${occ}" user:add "${username}"
    fi

    if "${occ}" user:info "${username}" | grep -q "^- enabled: false$"; then
        "${occ}" user:enable "${username}"
    fi
done < "${passwd}"

passwdUsers=$(echo "${passwdUsers}" | tail -n+2)

while IFS= read -r username; do
    if ! echo "${passwdUsers}" | grep -q "^${username}$"; then
        if "${occ}" user:info "${username}" | grep -q "^- enabled: true$"; then
            "${occ}" user:disable "${username}"
        fi
    fi
done < <("${occ}" user:list | cut -d':' -f1 | cut -c3-)
