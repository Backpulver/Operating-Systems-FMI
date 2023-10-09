#!/bin/bash

echo -n "Please enter your name: "
read -r name

if [[ $name =~ ^[A-Za-z\ \-]+$ ]]; then
	echo "Hello, $name"
else
	echo "Invalid name"
	exit 1
fi
