#!/bin/bash

if [[ $# -eq 1 ]] then
	echo "Hello, $1"
else
	echo "Can only make a greeting with 1 string"
fi
