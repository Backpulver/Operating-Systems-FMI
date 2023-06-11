#!/bin/bash

a=1
b=100
number=$(( (RANDOM % b) + a ))
if [[ $number -lt $a || $number -gt $b ]]; then
    echo "Error when generating number" >&2
    exit 1
fi

tries=1
while true; do
    echo -n "Guess? "
    read -r guess
    if [[ $guess -eq $number ]]; then
        echo "RIGHT! Guessed $number in $tries tries!"
        break
    elif [[ $guess -lt $number ]]; then
        echo "...bigger!"
    elif [[ $guess -gt $number ]]; then
        echo "...smaller!"
    fi
    ((tries++))
done