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
	
	if ! which jq > /dev/null
	then
		echo "jq is not installed."
		exit 1
	fi
}

function usage()
{
	echo "$0 - Control Belleds Q light bulbs"
	echo
	echo "Usage:"
	echo "   $0 [-l|--loop] [-h|--help]"
	echo
	echo "      -l | --loop - Continue to loop through the color setting dialog until cancel is pressed (useful for tweaking specific colors)"
	echo "      -h | --help - Display this message"
}

ARGS=$(getopt -o l,h -l "loop,help" -n "$0" -- "$@");
eval set -- "$ARGS"
loop=0
while true
do
	case "$1" in
		-l|--loop)
			loop=1
			shift
			;;
		-h|--help)
			usage
			shift
			exit 0
			;;
		--)
			shift
			break
			;;
	esac
done


sanityCheck
listBulbs
getBulbs

# Fake up a do...while loop (we always want to do this at least once)
keepGoing=1
until [ $keepGoing -ne 1 ]
do
	getColor
	JSON=$(buildColorJSON)
	sendCommand $JSON

	if [ $loop -ne 1 ]
	then
		keepGoing=0
	fi
done
