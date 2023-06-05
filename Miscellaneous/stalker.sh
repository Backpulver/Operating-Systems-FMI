#!/bin/bash 

while read -r line;
do
	username=$(echo "$line" | cut -d':' -f1) 
	if who | grep -q "$username"; then
		name=$(echo "$line" | cut -d':' -f5 | cut -d',' -f1)
		echo "$name"
	fi
done < /etc/passwd
