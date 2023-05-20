#!/bin/bash

echo "Enter your username: "
read -r username
if who | egrep "^$username" 2>/dev/null; then
	echo "Done"
else
	echo "Error, username is not found"
fi
