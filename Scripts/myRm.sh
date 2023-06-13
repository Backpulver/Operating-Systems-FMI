#!/bin/bash

if [[ $# -eq 0 ]]; then
    exit 0
fi

if [[ $1 == "-r" ]]; then
    startFrom=2
else
    startFrom=1
fi

if [[ ! -e ~/logs ]]; then
    echo "Creating directory ~/logs/"
    mkdir ~/logs
fi

if [[ ! -e ~/logs/remove.log ]]; then
    echo "Creating file ~/logs/remove.log"
    touch ~/logs/remove.log
fi

for ((i=startFrom; i<=$#; i++)); do
    arg="${!i}"

    if [[ -f "$arg" ]]; then
        if rm "$arg"; then
            echo "[$(date +%Y-%m-%d\ %T)] Removed file: $arg" >> ~/logs/remove.log
        else
            echo "Error when deleting the file: $arg" >&2
            exit 1
        fi
    elif [[ $1 == "-r" && -d "$arg" ]]; then
        if rm -rf "$arg"; then
            echo "Removed directory recursively: $arg" >> ~/logs/remove.log
        else
            echo "[$(date +%Y-%m-%d\ %T)] Error when deleting recursively the directory: $arg" >&2
            exit 2
        fi
    elif [[ -n $(find "$arg" -maxdepth 1 -empty) ]]; then
        if rmdir "$arg"; then
            echo "[$(date +%Y-%m-%d\ %T)] Removed directory: $arg" >> ~/logs/remove.log
        else
            echo "Error when deleting the directory: $arg" >&2
            exit 3
        fi
    else
        echo "$arg is invalid" >&2
        exit 4
    fi
done