#!/bin/bash

read -r dirPath

filesCount=$(find $dirPath -mindepth 1 -maxdepth 1 -type f | wc -l)
dirCount=$(find $dirPath -mindepth 1 -maxdepth 1 -type d | wc -l)

echo -e "Files: $filesCount\nDirectories: $dirCount"
