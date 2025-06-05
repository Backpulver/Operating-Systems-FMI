#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
	echo "Usage: ${0} <file>" >&2
    exit 1
fi

if [ ! -f "./bakefile" ]; then
    echo "Bakefile not found" >&2
    exit 2
fi

function bake() 
{
    if grep -qE "^${1}:" "./bakefile"; then
	    local newer=false
		dependencies=$(grep -E "^${1}:" "./bakefile" | awk -F ':' '{print $2}')
		
		for dep in ${dependencies}; do
			bake "${dep}"
			
			if [ "${dep}" -nt "${1}" ]; then
				newer=true
			fi
		done

		if [ "${newer}" == "true" ]; then
			command="$(grep -E "^${1}:" "./bakefile" | awk -F ':' '{print $3}')"
			eval "${command}"
		fi
	else
	    if [ ! -f "${1}" ] ; then
	    	echo "File: ${1} does not exist" >&2
			exit 3
		fi
	fi
}

bake "${1}"
