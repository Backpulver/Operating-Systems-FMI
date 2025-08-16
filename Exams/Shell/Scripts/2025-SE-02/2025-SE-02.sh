#!/bin/bash

set -euo pipefail

if [ -z "${SVC_DIR}" ]; then
    echo "SVC_DIR variable is not set" >&2
    exit 1
fi

if [ ! -d "${SVC_DIR}" ]; then
    echo "SVC_DIR is not a valid directory" >&2
    exit 2
fi

files=$(find "${SVC_DIR}" -maxdepth 1 -type f 2>/dev/null)

IsServiceRunning()
{
    local pidfile="${1}"
    
    if [ -f "${pidfile}" ]; then
        local pid=$(cat "${pidfile}")

        if ps -p "$pid" &> /dev/null; then
            return 0
        fi
    fi

    return 1
}

Start()
{
    local serviceName="${1}"

    for file in ${files}; do
        if grep -qo "^name: ${serviceName}$" "${file}"; then
            local comm=$(grep "^comm: +*" "$file"   | cut -d' ' -f2-)
            local outfile=$(grep "^outfile: +*" "$file" | cut -d' ' -f2-)
            local pidfile=$(grep "^pidfile: +*" "$file" | cut -d' ' -f2-)

            if IsServiceRunning "${pidfile}"; then
                continue
            fi

            eval "${comm}" &> "${outfile}" &
            local pid=$!
            echo "$pid" > "${pidfile}"
        fi
    done

    return 0
}

Stop()
{
    local serviceName="${1}"

    for file in ${files}; do
        if grep -qo "^name: ${serviceName}$" "${file}"; then
            local pidfile=$(grep "^pidfile: +*" "$file" | cut -d' ' -f2-)
            local pid=$(cat "${pidfile}")
            kill -SIGTERM "${pid}"
        fi
    done

    return 0
}

Running()
{
    local services=""

    for file in ${files}; do
        local pidfile=$(grep "^pidfile: +*" "$file" | cut -d' ' -f2-)

        if IsServiceRunning "${pidfile}"; then
            local name=$(grep "^name: +*" "$file" | cut -d' ' -f2-)
            services=$(echo -e "${services}\n${name}")
        fi
    done

    echo "${services}" | tail -n+2 | sort

    return 0
}

Cleanup()
{
    for file in ${files}; do
        local pidfile=$(grep "^pidfile: +*" "$file" | cut -d' ' -f2-)

        if ! IsServiceRunning "${pidfile}"; then
            if [ -f "${pidfile}" ]; then
                rm "${pidfile}"
            fi
        fi
    done

    return 0
}

PrintUsageError()
{
    echo "Usage:
          ${0} start <име на сървис>
          ${0} stop  <име на сървис>
          ${0} running
          ${0} cleanup" >&2
}

if [ "$#" -eq 1 ]; then
    if [[ "${1}" == "running" ]]; then
        Running
    elif [[ "${1}" == "cleanup" ]]; then
        Cleanup
    else
        PrintUsageError
        exit 3
    fi
elif [ "$#" -eq 2 ]; then
    if [[ "${1}" == "start" ]]; then
        Start "${2}"
    elif [[ "${1}" == "stop" ]]; then
        Stop "${2}"
    else
        PrintUsageError
        exit 4
    fi
else
    PrintUsageError
    exit 5
fi
