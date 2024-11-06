#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Not a root user!" 1>&2
    exit 1
fi

while IFS= read -r line; do
    username=$(echo "${line}" | cut -d':' -f1)
    homedir=$(echo "${line}" | cut -d':' -f6)

    if [ -z "${homedir}" ] || [ ! -d "${homedir}" ]; then
        echo "User ${username} does not have a home directory"
        continue
    fi

    owner=$(stat -c %U "${homedir}" 2>/dev/null)
    groupNameOfOwner=$(stat -c %G "${homedir}" 2>/dev/null)
    userWritePerm=$(stat -c %A "${homedir}" 2>/dev/null | cut -c3)
    groupWritePerm=$(stat -c %A "${homedir}" 2>/dev/null | cut -c6)
    othersWritePerm=$(stat -c %A "${homedir}" 2>/dev/null | cut -c9)
    groupsOfOwner=$(groups "${username}" | grep -qw "${groupNameOfOwner}")
    
    if [ "${username}" == "${owner}" ] && [ "${userWritePerm}" == "w" ]; then
        true 
    elif [ -n "${groupsOfOwner}" ] && [ "${groupWritePerm}" == "w" ]; then
        true
    elif [ "${othersWritePerm}" == "w" ]; then
        true
    else
        echo "User ${username} does not have write permissions for his home directory."
    fi
done < <(cat /etc/passwd)