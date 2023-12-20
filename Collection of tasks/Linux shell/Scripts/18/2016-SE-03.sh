#!/bin/bash

if [[ $(whoami) == "root" ]]; then
    while IFS= read -r line; do
        echo
    done
else
    echo "Not a root user!" 
    exit 1
fi