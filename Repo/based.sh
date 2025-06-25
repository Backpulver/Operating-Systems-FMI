#!/bin/bash

MAKEFILE_SOURCE="../../Makefile"
MAKEFILE_TEMP="./Makefile"

if ! cp "$MAKEFILE_SOURCE" "$MAKEFILE_TEMP"; then
    echo "Failed to copy Makefile from $MAKEFILE_SOURCE"
    exit 1
fi

make
MAKE_EXIT_CODE=$?
rm -f "$MAKEFILE_TEMP"

find . -type f -name "main.o" -delete 2>/dev/null
exit $MAKE_EXIT_CODE

