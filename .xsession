#!/usr/bin/env bash

[[ -f $HOME/.Xresources  ]] && xrdb -merge $HOME/.Xresources
[[ -f $HOME/.xprofile ]] && source $HOME/.xprofile

# setup the bell pings
xset b 15 200 150

# protect the screen after 60 minutes
xset s off
#xset dpms 600 1200 1800

# load up the fonts
#xset fp+ /usr/share/fonts/misc
#xset fp+ /usr/share/fonts/ohsnap
#xset fp+ /usr/share/fonts/terminesspowerline
#xset fp+ /usr/share/fonts/tewi
#fc-cache -v

# start powerline daemon
/usr/bin/powerline-daemon

#exec i3                            # start i3 without /etc/X11/Xsession.d/ goodies (dbus, gpg-agent, etc)
exec i3 >> ~/.i3/logfile           # start i3 with standard messages
#exec i3 -d all >> ~/.i3/logfile    # start i3 in debug mode
#exec i3 -V -d all >> ~/.i3/logfile # start i3 in super verbose mode
