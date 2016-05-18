#!/bin/bash

loc=$1

if [ "$loc" = "desk" ] ; then
    xrandr --output eDP1 --off
	xrandr --output DP2-2 --auto --right-of DP2-3
	xrandr --output DP2-1 --auto --left-of DP2-3
	xrandr --output DP2-3 --auto --left-of DP2-2
elif [ "$loc" = "laptop" ] ; then
	xrandr --output VGA1 --off
	xrandr --output LVDS1 --auto
	xrandr --output HDMI1 --off
else
	echo "switchdisplays <profile>"
	echo "profiles: 'desk' or 'laptop'"
	exit 1
fi
