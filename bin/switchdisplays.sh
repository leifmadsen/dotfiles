#!/bin/bash

loc=$1

if [ "$loc" = "desk" ] ; then
    xrandr --output eDP1 --off
	xrandr --output DP2-2 --auto --right-of DP2-3
	xrandr --output DP2-1 --auto --left-of DP2-3 --crtc 2
	xrandr --output DP2-3 --auto --left-of DP2-2 --crtc 1
elif [ "$loc" = "laptop" ] ; then
	xrandr --output DP2-1 --off
	xrandr --output DP2-2 --off
	xrandr --output DP2-3 --off
	xrandr --output eDP1 --auto
else
	echo "switchdisplays <profile>"
	echo "profiles: 'desk' or 'laptop'"
	exit 1
fi
