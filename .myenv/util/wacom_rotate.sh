#!/bin/sh

#Gets the current mode of the screen
mode="$(xrandr -q --verbose | grep 'connected' | egrep -o '\) (normal|left|inverted|right) \(' | egrep -o '(normal|left|inverted|right)')"

case "$mode" in
	normal)			#toggle rotate to the left
	xrandr -o right
	# "xsetwacom --list" to find out the list
	xsetwacom set "Wacom ISDv4 E6 Pen stylus" Rotate cw
	xsetwacom set "Wacom ISDv4 E6 Pen eraser" Rotate cw
	xsetwacom set "Wacom ISDv4 E6 Finger touch" Rotate cw
	#cellwriter --hide-window
	;;

	right)			#toggle rotate to normal
	xrandr -o normal
	# "xsetwacom --list" to find out the list
	xsetwacom set "Wacom ISDv4 E6 Pen stylus" Rotate none
	xsetwacom set "Wacom ISDv4 E6 Pen eraser" Rotate none
	xsetwacom set "Wacom ISDv4 E6 Finger touch" Rotate none
	#cellwriter --show-window
	;;
esac
