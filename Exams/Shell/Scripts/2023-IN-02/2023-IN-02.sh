#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} <directory>" >&2
    exit 1
fi

if [ ! -d "${1}" ]; then
    echo "${1} is not a valid direcotry" >&2
    exit 2
fi

files=$(find "${1}" -type f -printf "%i-%p\n")
list=""

for file in ${files}; do
    inode=$(echo "${file}" | cut -d'-' -f1)
    filename=$(echo "${file}" | cut -d'-' -f2-)
    hash=$(sha1sum "${filename}" | awk '{print $1}')
    list=$(echo -e "${list}\n${hash}@${inode}@${filename}")
done

uniqueHashes=$(echo "${list}" | tail -n+2 | cut -d'@' -f1 | sort -u)

for hash in ${uniqueHashes}; do
    files=$(echo "${list}" | grep "${hash}" | cut -d'@' -f2-)
    inodesCount=$(echo "${files}" | cut -d'@' -f1 | wc -l) 
    uniqInodesCount=$(echo "${files}" | cut -d'@' -f1 | sort -nu | wc -l)

    if [ "${inodesCount}" -eq "${uniqInodesCount}" ]; then
        # we have only duplicate files with no groups
        echo "${files}" | cut -d'@' -f2 | tail -n+2
    else
        # get all duplicate inodes for groups
        groupInodes=$(echo "${files}" | cut -d'@' -f1 | sort -n | uniq -d)
        groups=""

        for inode in ${groupInodes}; do
            file=$(echo "${files}" | grep "$inode" | cut -d'@' -f2)
            groups=$(echo -e "${groups}\n${file}")
        done

        echo "${groups}" | tail -n+2 | cut -d'@' -f2 | head -n1

        # the rest are files without a group
        duplicateFileInodes=$(echo "${files}" | cut -d'@' -f1 | sort -n | uniq -u)
        regularFiles=""

        for inode in ${duplicateFileInodes}; do
            file=$(echo "${files}" | grep "$inode" | cut -d'@' -f2)
            regularFiles=$(echo -e "${regularFiles}\n${file}")
        done

        echo "${regularFiles}" | tail -n+2 | cut -d'@' -f2
    fi
done