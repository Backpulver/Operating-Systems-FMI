#!/bin/bash

set -euo pipefail

for((i=0;i<10;i++)); do
    ps -eo comm,rss --no-headers | tr -s ' ' | rev | sed 's/ /@/' | rev | sort > info
    cat info | cut -d '@' -f 1 | sort | uniq > comms

    while read comm; do
        sum=$(cat info | grep "${comm}" | rev | cut -d '@' -f 1 | rev | tr '\n' '+' | rev |cut -c 2- | rev | bc)
        echo "${comm}@${sum}" >> info_comms
    done < <(cat comms)

    sleep 1
done

cat info_comms | cut -d '@' -f 1 | sort | uniq > comms

while read comm; do
    sreshtaniq=$(echo "$(grep "${comm}" info_comms | wc -l) / 2" | bc)
    middle=$(grep "${comm}" info_comms | sort -n -t '@' -k 2 | tail -n ${sreshtaniq} | head -n 1 | cut -d '@' -f 2)
    
    if [[ middle -gt 65536 ]]; then
        echo "${comm}"
    fi
done < <(cat comms)