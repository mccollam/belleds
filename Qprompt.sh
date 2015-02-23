#!/bin/bash
# This should not be run directly, but set with PROMPT_COMMAND in bash
# Update the 'serials' to the serial number of the bulb to control
# Use it like this:
# PROMPT_COMMAND='./Qprompt $?'
serials=("MD1AC44200001127")
dir="$(dirname $0)"
if ! . $dir/environment.conf ; then echo "Unable to load settings." && exit 1 ; fi
if ! . $dir/lib.sh ; then echo "Unable to load function library." && exit 1 ; fi

if [ $1 -eq 0 ]
then
	red=0
	green=255
else
	red=255
	green=0
fi

JSON=$(buildColorJSON)
sendCommand $JSON
