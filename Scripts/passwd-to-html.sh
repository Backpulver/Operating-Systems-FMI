#!/bin/bash

echo -e "<table>\n  <tr>\n    <th>Username</th>\n    <th>group</th>\n    <th>login shell</th>\n    <th>GECOS</th>\n  </tr>"

while IFS= read -r line
do
    username=$(echo "$line" | cut -d':' -f1)
    group=$(echo "$line" | cut -d':' -f4)
    loginShell=$(echo "$line" | cut -d':' -f7)
    gecos=$(echo "$line" | cut -d':' -f5)
    fields=("$username" "$group" "$loginShell" "$gecos")

    echo " <tr>"

    for field in "${fields[@]}"; do
        echo "  <th>$field</th>"
    done

    echo " </tr>"
done < /etc/passwd

echo -n "</table>"