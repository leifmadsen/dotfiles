#!/usr/bin/env bash

[[ -f $HOME/.Xresources  ]] && xrdb -merge $HOME/.Xresources

# setup the bell pings
xset b 15 200 150

# protect the screen after 60 minutes
xset s off
xset dpms 3600 3600 3600

# load up the fonts
xset fp+ $HOME/.fonts/misc
xset fp+ $HOME/.fonts/ohsnap
xset fp+ $HOME/.fonts/terminesspowerline
xset fp+ $HOME/.fonts/tewi

exec i3                            # start i3 without /etc/X11/Xsession.d/ goodies (dbus, gpg-agent, etc)
#exec i3 >> ~/.i3/logfile           # start i3 with standard messages
#exec i3 -d all >> ~/.i3/logfile    # start i3 in debug mode
#exec i3 -V -d all >> ~/.i3/logfile # start i3 in super verbose mode
