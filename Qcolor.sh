#!/bin/bash

# Simple shell script to control Belleds Q station light colors
# Requires netcat (nc) and zenity to be installed
# 2015-02-22 Ronald McCollam <mccollam@gmail.com>

dir="$(dirname $0)"
if ! . $dir/environment.conf ; then echo "Unable to load settings." && exit 1 ; fi
if ! . $dir/lib.sh ; then echo "Unable to load function library." && exit 1 ; fi

function sanityCheck()
{
	if ! which zenity > /dev/null
	then
		echo "Zenity is not installed."
		exit 1
	fi
	
	if ! which nc > /dev/null
	then
		echo "Netcat is not installed."
		exit 1
	fi
}

sanityCheck
getBulbs
getColor
JSON=$(buildColorJSON)

sendCommand $JSON
