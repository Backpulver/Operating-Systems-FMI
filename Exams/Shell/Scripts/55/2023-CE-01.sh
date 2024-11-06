#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <CSV_file>  <star_type>"
    exit 1
fi

if [[ ! -f $1 ]]; then
    echo "$1 is not a file"
    exit 2
fi

if ! [[ $(file $1) =~ CSV ]]; then
    echo "$1 is not a CSV file"
    exit 3
fi

filteredFile=""

while IFS= read -r line || [ -n "$line" ]; do
    type=$(echo $line | cut -d',' -f5)
    if [[ $type == $2 ]]; then
        toForth=$(echo $line | cut -d',' -f1-4)
        toTheEnd=$(echo $line | cut -d',' -f6-)
        filteredFile+="$toForth,$type,$toTheEnd\n"
    fi
done < $1

filteredFile=$(echo -e "$filteredFile" | sed '$d')

rankContellation=$(echo "$filteredFile" | cut -d',' -f4 | sort | uniq -c | sed -E s/^\ +//)
contellation=$(echo "$rankContellation" | sort -n -t' ' -k1,1 | tail -n1 | cut -d' ' -f2)

filteredFile=""
while IFS= read -r line || [ -n "$line" ]; do
    magnitude=$(echo $line | cut -d',' -f7)
    if ! [[ $magnitude =~ -- ]]; then
        filteredFile+="$line\n"
    fi
done < $1

filteredFile=$(echo -e "$filteredFile" | sed '$d')

echo "$filteredFile" | grep "$contellation" | sort -n -t',' -k7,7 | head -n1
