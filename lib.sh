#!/bin/bash

# Library of functions for Belleds Q Station and bulbs
# 2015-02-22 Ronald McCollam <mccollam@gmail.com>

function getColor()
{
	# This probably shouldn't rely on just setting the r/g/b variables
	# but it's quick and easy.
	
	# Get existing color (if any; for looping) as hex:
	if [[ $red = "" ]] ; then red=255 ; fi
	if [[ $green = "" ]] ; then green=255 ; fi
	if [[ $blue = "" ]] ; then blue=255 ; fi
	cur=`printf "#%02X%02X%02X" $red $green $blue`

	if color=`zenity --color-selection --color=$cur`
	then
		# Convert from hex to a tuple of RGB in decimal
		# NB: It seems at least some versions of zenity return color
		# strings that are 'doubled' or have extra characters.  Attempt
		# to detect this and work around it.
		if [ ${#color} -gt 7 ]
		then
			# doubled characters detected
			red=$((16#`echo $color | cut -c2-3`))
			green=$((16#`echo $color | cut -c6-7`))
			blue=$((16#`echo $color | cut -c10-11`))
		else
			# standard 6-characters
			red=$((16#`echo $color | cut -c2-3`))
			green=$((16#`echo $color | cut -c4-5`))
			blue=$((16#`echo $color | cut -c6-7`))
		fi
	else
		echo "You must select a color!"
		exit 1
	fi
}

function getBulbs()
{
	# This relies on listBulbs() having been called first!
	
	if [ ${#bulbserials} -eq 0 ]
	then
		echo "ERROR: Empty bulb list!  Is your Q station online (and did your script call listBulbs())?"
		exit 1
	fi
	
	bulblist=`for (( i=0 ; i<${#bulbserials[@]} ; i++ )) ; do echo -n "TRUE ${bulbserials[$i]} ${bulbnames[$i]} "; done`
	if selection=`zenity --width 400 --height 400 --list --checklist --multiple --separator=',' --text "Select one or more bulbs" --column "Selected" --column "Serial Number" --column "Name" $bulblist`
	then
		selection=`echo $selection | sed s/\"//g`
		oldIFS="$IFS"
		IFS=,
		serials=( $selection )
		IFS="$oldIFS"
	else
		echo "No bulbs selected!"
		exit 1
	fi
}

function getSingleBulb()
{
	# This relies on listBulbs() having been called first!
	
	if [ ${#bulbserials} -eq 0 ]
	then
		echo "ERROR: Empty bulb list!  Is your Q station online (and did your script call listBulbs())?"
		exit 1
	fi
	
	bulblist=$(for (( i=0 ; i<${#bulbserials[@]} ; i++ )) ; do echo -n "FALSE ${bulbserials[$i]} ${bulbnames[$i]} " ; done)
	if selection=`zenity --width 400 --height 400 --list --radiolist --text "Select a bulb" --column "Selected" --column "Serial Number" --column "Name" $bulblist`
	then
		serial=`echo $selection | sed s/\"//g`
		if [ ! "$serial" ]
		then
			echo "No bulb selected!"
			exit 1
		fi
	else
		echo "No bulb selected!"
		exit 1
	fi
}

function listBulbs()
{
	# Get the list of bulbs known by the Q station and populate the
	# bulb array
	
	bulbJSON=$(sendCommandGetResponse "{ 'cmd':'light_list' }")
	
	# We need to have two arrays rather than a single associative array
	# because it's valid to have two bulbs with the same name
	# (indeed, this is the default state)
	# TODO: There's probably a more efficient way to use jq here
	read -a bulbnames <<< `echo $bulbJSON | jq '[.led][][].title' | sed s/\ /_/g | sed s/\"//g`
	read -a bulbserials <<< `echo $bulbJSON | jq '[.led][][].sn' | sed s/\"//g`
}

function buildColorJSON()
{
	# If we ask for white light, we should switch the bulb into the
	# special mode it uses for white rather than just setting all the
	# color values to 255:
	if [ $red -eq 255 ] && [ $green -eq 255 ] && [ $blue -eq 255 ]
	then
		effect=8 # white
	else
		effect=9 # color
	fi
	
	# Similarly, if everything is 0, we should just turn the light off:
	if [ $red -eq 0 ] && [ $green -eq 0 ] && [ $blue -eq 0 ]
	then
		iswitch=0 # off
	else
		iswitch=1 # on
	fi
	
	colorJSON="'r':'$red', 'g':'$green', 'b':'$blue', 'bright':'100'"
	serialJSON=`for s in "${serials[@]}" ; do echo -n "{ 'sn':'$s' }, " ; done`
	JSON="{ 'cmd':'light_ctrl', $colorJSON, 'sn_list':[ $serialJSON ], 'iswitch':'$iswitch', 'matchValue':'0', 'effect':'$effect' }"
	echo $JSON
}

function setBulbNameJSON()
{
	# Expects two parameters, bulb serial number and bulb name

	echo "{ 'cmd':'set_title', 'sn':'$1', 'title':'$2' }"
}

function getBulbName()
{
	# Retrieve a name of a bulb based on the serial number
	for (( i=0 ; i<${#bulbserials[@]} ; i++ ))
	do
		if [ "${bulbserials[$i]}" = "$1" ]
		then
			echo "${bulbnames[$i]}"
		fi
	done
}

function getNewBulbName()
{
	# Can optionally pass in a default name for the bulb
	if ! name=`zenity --entry --title "Name a bulb" --text="Enter a new name for the bulb:" --entry-text="$1"`
	then
		echo "No name specified!"
		exit 1
	fi
	
	if [ ! "$name" ]
	then
		echo "Name cannot be blank!"
		exit 1
	fi
}

function sendCommand()
{
	# Blast it to the Q station without waiting for a reply (ugly, but fast)
	echo $@ | nc -u $QstationIP 11600 -w0
}

function sendCommandGetResponse()
{
	# Send command to the Q station and return a response
	echo `echo $@ | nc -u $QstationIP 11600 -w1`
}
