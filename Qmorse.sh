#!/bin/bash

# Send Morse code messages via Belleds Q station lights
# Requires netcat (nc) and zenity to be installed
# 2015-02-22 Ronald McCollam <mccollam@gmail.com>

dir="$(dirname $0)"
if ! . $dir/environment.conf ; then echo "Unable to load settings." && exit 1 ; fi
if ! . $dir/lib.sh ; then echo "Unable to load function library." && exit 1 ; fi

# Set this to 0 if you don't want the text displayed as it is sent
showText=1

# Speed settings -- timings from http://en.wikipedia.org/wiki/Morse_code#Representation.2C_timing_and_speeds
# This is actually fairly slow, but this seems to be about the upper
# bound on how quickly the Q bulbs can toggle on/off effectively
dotDuration=0.2
dashDuration=0.6
gapDuration=$dotDuration
shortGap=0.6
mediumGap=1.4

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

function on()
{
	red=255 ; green=255 ; blue=255
	JSON=$(buildColorJSON)
	sendCommand $JSON
}

function off()
{
	red=0 ; green=0 ; blue=0
	JSON=$(buildColorJSON)
	sendCommand $JSON
}

function dash()
{
	on
	wait $dashDuration
	off
	wait $gapDuration
}

function dot()
{
	on
	wait $dotDuration
	off
	wait $gapDuration
}

function wait()
{
	# This was a more useful function when debugging :)
	sleep $1
}

function showChar()
{
	if [ $showText -ne 0 ]
	then
		if [ "$1" = "#" ]
		then
			echo -n " "
		else
			echo -n $1
		fi
	fi
}

function getMessage()
{
	if ! message=`zenity --entry --text="Enter the message you want to send:"`
	then
		echo "You must enter a message!"
	fi
	
	# Standardize case and mark spaces (to use for longer gaps)
	message=`echo $message | tr '[:upper:]' '[:lower:]' | sed s/\ /\#/g`
}

function textToMorse()
{
	for (( i=0 ; i<${#message} ; i++ ))
	do
		char=${message:$i:1}
		showChar $char
		case $char in
			a)
				dot ; dash
				wait $shortGap
				;;
			b)
				dash ; dot ; dot ; dot
				wait $shortGap
				;;
			c)
				dash ; dot ; dash ; dot
				wait $shortGap
				;;
			d)
				dash ; dot ; dot
				wait $shortGap
				;;
			e)
				dot
				wait $shortGap
				;;
			f)
				dot ; dot ; dash ; dot
				wait $shortGap
				;;
			g)
				dash ; dash ; dot
				wait $shortGap
				;;
			h)
				dot ; dot ; dot ; dot
				wait $shortGap
				;;
			i)
				dot ; dot
				wait $shortGap
				;;
			j)
				dot ; dash ; dash ; dash
				wait $shortGap
				;;
			k)
				dash ; dot ; dash
				wait $shortGap
				;;
			l)
				dot ; dash ; dot ; dot
				wait $shortGap
				;;
			m)
				dash ; dash
				wait $shortGap
				;;
			n)
				dash ; dot
				wait $shortGap
				;;
			o)
				dash ; dash ; dash
				wait $shortGap
				;;
			p)
				dot ; dash ; dash ; dot
				wait $shortGap
				;;
			q)
				dash ; dash ; dot ; dash
				wait $shortGap
				;;
			r)
				dot ; dash ; dot
				wait $shortGap
				;;
			s)
				dot ; dot ; dot
				wait $shortGap
				;;
			t)
				dash
				wait $shortGap
				;;
			u)
				dot ; dot ; dash
				wait $shortGap
				;;
			v)
				dot ; dot ; dot ; dash
				wait $shortGap
				;;
			w)
				dot ; dash ; dash
				wait $shortGap
				;;
			x)
				dash ; dot ; dot ; dash
				wait $shortGap
				;;
			y)
				dash ; dot ; dash ; dash
				wait $shortGap
				;;
			z)
				dash ; dash ; dot ; dot
				wait $shortGap
				;;
			1)
				dot ; dash ; dash ; dash ; dash
				wait $shortGap
				;;
			2)
				dot ; dot ; dash ; dash ; dash
				wait $shortGap
				;;
			3)
				dot ; dot ; dot ; dash ; dash
				wait $shortGap
				;;
			4)
				dot ; dot ; dot ; dot ; dash
				wait $shortGap
				;;
			5)
				dot ; dot ; dot ; dot ; dot
				wait $shortGap
				;;
			6)
				dash ; dot ; dot ; dot ; dot
				wait $shortGap
				;;
			7)
				dash ; dash ; dot ; dot ; dot
				wait $shortGap
				;;
			8)
				dash ; dash ; dash ; dot ; dot
				wait $shortGap
				;;
			9)
				dash ; dash ; dash ; dash ; dot
				wait $shortGap
				;;
			0)
				dash ; dash ; dash ; dash ; dash
				wait $shortGap
				;;
			\.)
				dot ; dash ; dot ; dash ; dot ; dash
				wait $mediumGap
				;;
			\,)
				dash ; dash ; dot ; dot ; dash ; dash
				wait $mediumGap
				;;
			\?)
				dot ; dot ; dash ; dash ; dot ; dot
				wait $mediumGap
				;;
			\')
				dot ; dash ; dash ; dash ; dash ; dot
				wait $mediumGap
				;;
			\!)
				dash ; dot ; dash ; dot ; dash ; dash
				wait $mediumGap
				;;
			\/)
				dash ; dot ; dot ; dash ; dot
				wait $mediumGap
				;;
			\()
				dash ; dot ; dash ; dash ; dot
				wait $mediumGap
				;;
			\))
				dash ; dot ; dash ; dash ; dot ; dash
				wait $mediumGap
				;;
			\&)
				dot ; dash ; dot ; dot ; dot
				wait $mediumGap
				;;
			\:)
				dash ; dash ; dash ; dot ; dot ; dot
				wait $mediumGap
				;;
			\;)
				dash ; dot ; dash ; dot ; dash ; dot
				wait $mediumGap
				;;
			\=)
				dash ; dot ; dot ; dot ; dash
				wait $mediumGap
				;;
			\+)
				dot ; dash ; dot ; dash ; dot
				wait $mediumGap
				;;
			\-)
				dash ; dot ; dot ; dot ; dot ; dash
				wait $mediumGap
				;;
			\_)
				dot ; dot ; dash ; dash ; dot ; dash
				wait $mediumGap
				;;
			\")
				dot ; dash ; dot ; dot ; dash ; dot
				wait $mediumGap
				;;
			\$)
				dot ; dot ; dot ; dash ; dot ; dot ; dash
				wait $shortGap
				;;
			\@)
				dot ; dash ; dash ; dot ; dash ; dot
				wait $shortGap
				;;
			\#)
				wait $mediumGap
				;;
			*)
				;;
		esac
		
	done
}

listBulbs
getBulbs
getMessage

# Turn light off to start
off
wait $mediumGap

textToMorse
