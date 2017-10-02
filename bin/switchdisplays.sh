#!/bin/bash

loc=$1

if [ "$loc" = "desk" ] ; then
    xrandr --output eDP-1 --off
    xrandr --output DP-2-1 --off
    xrandr --output DP-2-3 --off
    xrandr --output DP-2-2 --off
    sleep 1
    xrandr --output DP-2-1 --auto --primary --left-of DP-2-2 #--crtc 1
    xrandr --output DP-2-2 --auto --right-of DP-2-1 #--crtc 2
    xrandr --output DP-2-3 --auto --right-of DP-2-2
elif [ "$loc" = "laptop" ] ; then
    xrandr --output DP-2-1 --off
    xrandr --output DP-2-2 --off
    xrandr --output DP-2-3 --off
    sleep 2
    xrandr --output eDP-1 --auto
else
    echo "switchdisplays <profile>"
    echo "profiles: 'desk' or 'laptop'"
    exit 1
fi
