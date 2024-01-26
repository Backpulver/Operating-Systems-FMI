#!/bin/bash

if ! [[ $(whoami) == "root" ]]; then
    echo "Not a root user!" 
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    username=$(echo $line | cut -d':' -f1)
    homedir=$(echo $line | cut -d':' -f6)

    if [[ -z "$homedir" ]] || [[ ! -d "$homedir" ]]; then
        echo "User $username does not have a home directory"
    else
        if [[ ! -w "$homedir" ]]; then
            echo "User $username does not have write permissions for his home directory"
        fi
    fi
done < /etc/passwd