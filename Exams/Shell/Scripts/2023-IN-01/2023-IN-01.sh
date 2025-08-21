#!/bin/bash

set -euo pipefail

if [ "$#" -gt 2 ]; then
    echo "Usage: ${0} [autoconf/config]"
    exit 1
fi

slots="0"

checkEnvVariable()
{
    if printenv CTRLSLOTS &>/dev/null; then
        slots=""

        for slot in ${CTRLSLOTS}; do
            if echo "${slot}" | grep -Eq "^(0|[1-9][0-9]*)$"; then
                slots="${slots} ${slot}"
            fi
        done

        slots=$(echo "${slots}" | cut -c2-)

        if [ -z "${slots}" ]; then
            echo "No slot numbers in variable CTRLSLOTS" >&2
            exit 2
        fi
    fi
}

getSlotInfo()
{
    if [[ "${1}" != "label" && "${1}" != "temp" ]]; then
        return
    fi

    for slot in ${slots}; do
        # rename to "ssacli" to get the actual solution
        output=$(sudo ./ssacli.sh ctrl slot="${slot}" pd all show detail)
        if [ "$?" -ne 0 ]; then
            echo "Error invoking ssacli as root!"
            exit 3
        else
            controllerModule=$(echo "${output}" | head -n1 | grep -Eo "Array [^ ]+" | cut -d' ' -f2)
            array=""
            drive=""
            temperature=""

            while IFS= read -r line; do
                # level 1 indentation
                if echo "${line}" | grep -Pq "^ {3}Unassigned\s*$"; then
                    array="UN"
                    drive=""
                    continue
                fi

                if echo "${line}" | grep -Pq "^ {3}Array\s+[^ ]+\s*$"; then
                    array=$(echo "${line}" | grep -P "^ {3}Array\s+[^ ]+\s*$" | awk '{print $2}')
                    drive=""
                    continue
                fi

                # level 2 indentation
                if echo "${line}" | grep -Pq "^ {6}physicaldrive\s+[^ ]+\s*$"; then
                    drive=$(echo "${line}" | grep -P "^ {6}physicaldrive\s+[^ ]+\s*$" | awk '{print $2}')
                    continue
                fi

                # level 3 indentation
                if echo "${line}" | grep -Pq "^ {9}Current Temperature \(C\):\s+\d+\s*$"; then
                    temperature=$(echo "${line}" | grep -P "^ {9}Current Temperature \(C\):\s+\d+\s*$" | awk '{print $4}')

                    if [ -n "${array}" ] && [ -n "${drive}" ]; then
                        id=$(echo "SSA${slot}${controllerModule}${array}$(echo "${drive}" | tr -d ':')")

                        if [ "${1}" == "label" ]; then
                            echo "${id}.label SSA${slot} ${controllerModule} ${array} ${drive}"
                            echo "${id}.type GAUGE"
                        fi

                        if [ "${1}" == "temp" ]; then
                            echo "${id}.value ${temperature}"
                        fi
                    fi

                    continue
                fi
            done < <(echo "${output}")
        fi
    done
}

if [ "$#" -eq 1 ]; then
    if [ "$1" == "autoconf" ]; then
        echo "yes"
        exit 0
    elif [ "$1" == "config" ]; then
        checkEnvVariable
        
        echo "graph_title SSA drive temperatures"
        echo "graph_vlabel Celsius"
        echo "graph_category sensors"
        echo "graph_info This graph shows SSA drive temp"

        getSlotInfo label
    else
        echo "Usage: ${0} [autoconf/config]"
        exit 4
    fi
else
    checkEnvVariable
    getSlotInfo temp
fi
