#!/bin/bash

# Use a Q light to indicate the completeness of a long-running command
# (Light will turn green for success, red for failure)

# Set this to the serial number of the bulb to use for notification:
serials=("MD1AC44200001127")

dir="$(dirname $0)"
if ! . $dir/environment.conf ; then echo "Unable to load settings." && exit 1 ; fi
if ! . $dir/lib.sh ; then echo "Unable to load function library." && exit 1 ; fi

if [ $# -lt 1 ]
then
	echo No command specified!
	echo
	echo Usage: $0 command [arguments...]
	exit 0
fi

$@

if [ $? -eq 0 ]
then
	red=0
	blue=0
	green=255
else
	red=255
	blue=0
	green=0
fi

JSON=$(buildColorJSON)
sendCommand $JSON
