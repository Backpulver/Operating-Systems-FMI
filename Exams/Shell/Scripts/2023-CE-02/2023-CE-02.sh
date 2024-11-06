#!/bin/bash

if [[ ${#} -ne 3 ]]; then
	echo "Err" 
fi

zastoqnie1=$(grep -Eo "^${3}: [1-9][0-9]* megaparsecs$" "${1}")
echo "$zastoqnie1"
