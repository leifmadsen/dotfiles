#!/bin/bash

loc=$1

if [ "$loc" = "desk" ] ; then
	xrandr --output VGA1 --auto --right-of HDMI1
	xrandr --output LVDS1 --off
	xrandr --output HDMI1 --auto --left-of VGA1
elif [ "$loc" = "laptop" ] ; then
	xrandr --output VGA1 --off
	xrandr --output LVDS1 --auto
	xrandr --output HDMI1 --off
else
	echo "switchdisplays <profile>"
	echo "profiles: 'desk' or 'laptop'"
	exit 1
fi
