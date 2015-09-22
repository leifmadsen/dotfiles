# setup the bell pings
/usr/bin/xset b 15 200 150

# protect the screen after 60 minutes
/usr/bin/xset s off
/usr/bin/xset dpms 3600 3600 3600

# load up the fonts
/usr/bin/xset fp+ $HOME/.fonts/misc
/usr/bin/xset fp+ $HOME/.fonts/ohsnap
/usr/bin/xset fp+ $HOME/.fonts/terminesspowerline
/usr/bin/xset fp+ $HOME/.fonts/tewi

/usr/bin/i3

#exec i3                            # start i3 without /etc/X11/Xsession.d/ goodies (dbus, gpg-agent, etc)
#exec i3 >> ~/.i3/logfile           # start i3 with standard messages
#exec i3 -d all >> ~/.i3/logfile    # start i3 in debug mode
#exec i3 -V -d all >> ~/.i3/logfile # start i3 in super verbose mode
