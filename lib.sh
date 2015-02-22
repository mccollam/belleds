#!/bin/bash

# Library of functions for Belleds Q Station and bulbs
# 2015-02-22 Ronald McCollam <mccollam@gmail.com>

function getColor()
{
	# This probably shouldn't rely on just setting the r/g/b variables
	# but it's quick and easy.
	
	if color=`zenity --color-selection`
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
	# This probably shouldn't rely on just setting the bulb array
	# as a variable but it's quick and easy.
	
	bulblist=`for b in "${!bulbs[@]}"; do echo -n "TRUE \"$b\" "; done`
	if selection=`zenity --list --checklist --multiple --separator=',' --text "Select one or more bulbs" --column "Selected" --column "Bulb" $bulblist`
	then
		selection=`echo $selection | sed s/\"//g`
		oldIFS="$IFS"
		IFS=,
		selectedbulbs=( $selection )
		serials=()
		for s in "${selectedbulbs[@]}"
		do
			serials+=(${bulbs[$s]})
		done
		IFS="$oldIFS"
	else
		echo "No bulbs selected!"
		exit 1
	fi
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
	
	colorJSON="'r':'$red', 'g':'$green', 'b':'$blue', 'bright':'255'"
	serialJSON=`for s in "${serials[@]}" ; do echo -n "{ 'sn':'$s' }, " ; done`
	JSON="{ 'cmd':'light_ctrl', $colorJSON, 'sn_list':[ $serialJSON ], 'iswitch':'1', 'matchValue':'0', 'effect':'$effect' }"
	echo $JSON
}

function sendCommand()
{
	# Blast it to the Q station without waiting for a reply (ugly, but fast)
	echo $@ | nc -u $QstationIP 11600 -w0
}
