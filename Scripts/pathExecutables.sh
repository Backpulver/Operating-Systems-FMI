#!/bin/bash

# This is the solution for hint1
# 
# pathDirs=$(echo "$PATH" | tr ':' '\n')
# sum=0
# for dir in $pathDirs; do
#     ((sum+=$(find "$dir" -type f -executable 2>/dev/null | wc -l)))
# done
# echo "The number of executeable files in PATH is: $sum"

# solution for hint2 
# 
sum=0
while IFS= read -r line; do
    ((sum+=$(find "$line" -type f -executable 2>/dev/null | wc -l)))
done <<< "$(echo "$PATH" | tr ':' '\n')"

echo "The number of executeable files in PATH is: $sum"