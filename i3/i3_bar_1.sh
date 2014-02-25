#!/bin/bash
#
# Copyright (C) 2013 Andrew J. Bibb
# License: MIT 
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software 
# is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Script to add custom notifications to the i3bar
#
# 2013-05-26  show firewall status
# 2013-06-04  added weather alerts
# 2013.07.10  revised and cleaned up code
# 2013.08.23  major rewrite, adopted jshon to create and manipulate JSON objects
#             added caps and num lock state
# 2013.10.06  added code to check for mouse clicks in the bar
# 2013.10.08  added field for reminder text
# 2013.10.09  added song info from ncmpcpp
# 2013.10.24  expanded comments at the top of the listing
# 2013.10.28  added click event to weather field
#
#
# For this script to work the config file for your bar should contain the following 
# lines in the general section:
#
#     general {
#       output_format = i3bar
#       colors = true
#       interval = 5
#     }
#
# The interval value can be set to something other than 5 (seconds), the other
# two lines are required.
#
# To call this script your ~/.i3/config file needs to contain a line like this:
#
#     bar {
#       status_command ~/.config/i3status/i3_bar_1.sh
#     }
#
# Assuming that you name this script i3_bar_1.sh and that the path above
# is where you choose to place it.
#
# The following packages are necessary to run this script.  Generally if 
# a necessary package is not found that piece of the script will be skipped.
# The idea is not to crash the script if something is missing, but it may 
# make finding out why something is not working difficult.
#
#     jshon - required for the script to parse JSON data 
#     xset  - required for Num/Caps lock function
#
# Note: this script is provided mainly to provide a framework to hack on
# for your own customizations.  Functions to create text fields for injection
# into the JSON stream and to read and process mouse clicks are provided mainly
# for example.  It is not likely they will work on your machine out of the box, 
# with the possible exception of the Num/Caps lock function.  
#
# We use custom config files for our bars, and they are called on this line down
# around line 380 or so.
#
#   i3status --config ~/.config/i3status/config_bar_1  | (read line && read line && while :
#
# You must either modify that line to point to your config, or to use the default
# config file change the line thus: 
#
#   i3status | (read line && read line && while :
#
############################### Functions ###################################

#
# All possible JSON entries for the i3bar (for reference)
 # full_text              Text string to display
 # short_text             Text to display if there is not enough room for full text
 # color                  Color of the text to display in the block
 # min_width              The minimum width (in pixels) of the block.
 # align                  One of [left|center|right] center is default
 # urgent                 One of [true|false] specifies whether the current value is urgent
 # name                   Every block should have a unique name 
 # instance               use if we have duplicate names 
 # separator              One of [true|false] true=draw separator
 # separator_block_width  default is 9, use odd number with separator

# 
# In the functions below we've broken the code to generate a JSON object into separate lines.  
# This is not necessary and is only done to aid in reading.  To build your JSON object first
# seed the jshon utility with the "line" variable and then create a new object on the stack:
# start with:
#     echo ${line} | jshon -n object
#
# Following the object you create all of the key:value pairs that you want.  The format to 
# do this is a bit counterintitutive in that to enter a key:value pair you must first enter
# the value, then the key.  Use the following flags:
#     -s for any string value
#     -n for any true, false, integer or float value
#     -i for all of the keys
# 
# Lastly you want to insert the object you've created on the stack into the underlying JSON. 
# The position you send as an argument can be 0 (the number zero) to put it at the front,
# the word append to put it at the end, or another number to put it at that position.  If you
# specify a number larger than the number of positions in the underlying array jshon will cycle
# around to the top and start counting again, and will keep doing this until it is left with a
# number less than the number of positions, and will then insert it.  Long way of saying if you
# want your value to be the last element use append.  Insert the stack object thusly:
#       -i ${1} 
#
# Each function requires one argument which is the position to insert the JSON element into the array.

#
# function to set the bar display for Caps Lock on or off
getCapLockState()
{
  # argument is mandatory
  [[ -z ${1} ]] && return 11
    
  # variables
  local col=
    
  # set output text color based on the key state
  [[ -n $(echo ${xs} | grep "Caps Lock:\s*on") ]] && col="${col_normal}" || col="${col_shadow}"
  
  # build the JSON object
  line=$(echo ${line} | jshon -n object \
  -s caps_lock -i name          \
  -s CAP -i full_text           \
  -s A -i short_text            \
  -s "#${col}" -i color         \
  -s center -i align            \
  -n false -i urgent            \
  -n false -i separator         \
  -n 8 -i separator_block_width \
  -i ${1})
    
  return 0
}

#
# function to set the bar display for Num Lock on or off
getNumLockState()
{
  # argument is mandatory
  [[ -z ${1} ]] && return 11
  
  # variables
  local col=
  
  # set output text color based on the key state
  [[ -n $(echo ${xs} | grep "Num Lock:\s*on") ]] && col="${col_normal}" || col="${col_shadow}"
  
  line=$(echo ${line} | jshon -n object \
  -s num_lock -i name           \
  -s NUM -i full_text           \
  -s 1 -i short_text            \
  -s "#${col}" -i color         \
  -s center -i align            \
  -n false -i urgent            \
  -n true -i separator          \
  -n 9 -i separator_block_width \
  -i ${1})
    
  return 0
}

#
# function to get weather alerts or temp/pressure information
# basically just cat files created by our weather scripts
getWeatherInfo()
{
  # argument is mandatory
  [[ -z ${1} ]] && return 11
    
  # variables
  local nws=
  local urg=  
  local col=
  
  # Call weather script and get the weather alerts. The script will create the short_sum.txt
  # and alert_level.txt files if needed.  Then cat the files for the information we need.
  ~/Utilities/weather/getWeatherData.sh
  nws=$(cat /tmp/myles_weather/short_sum.txt) 
  
  # set urgent or not urgent based on the alert level (urgent if alert_level > 0)
  if [[ $(cat /tmp/myles_weather/alert_level.txt) -gt 0 ]]; then
    urg=true
    col=${col_warning}
  else 
    urg=false
    col=${col_normal}
  fi
  
  # build the JSON object
  line=$(echo ${line} | jshon -n object   \
  -s weather -i name            \
  -s "${nws}" -i full_text      \
  -s "#${col}" -i color  \
  -s center -i align            \
  -n "${urg}" -i urgent         \
  -n true -i separator          \
  -n 9 -i separator_block_width \
  -i ${1})  

  return 0
}

#
# function to determine the firewall status as stored in 
# /usr/bin/myles_apps/fwsetup/fw_conf.txt
getFireWallStatus()
{
  # argument is mandatory
  [[ -z ${1} ]] && return 11
     
  # define a constant for the output
  local readonly fw_pfix="FW: "
   
  # variables
  local fwstatus=
  local fwcol=
   
  # read the firewall status from fw_conf.txt
  fwstatus=$(cat /usr/bin/myles_apps/fwsetup/fw_conf.txt)
   
  # assign a fwcol depending on status.  Test statements are from
  # our fw_options (inside myles-apps) script, so if they ever change
  # this function will no longer work.
  case ${fwstatus} in
    Home)     fwcol=${col_partup} ; fwstatus="${fw_pfix}Home";;
    Public)   fwcol=${col_fullup} ; fwstatus="Shields Up" ;;
    Disabled) fwcol=${col_warning} ; fwstatus="Shields Down" ;;
    *)        fwcol=${col_caution} ; fwstatus="${fw_pfix}Unknown" ;;
  esac; 
   
  # build the JSON object
  line=$(echo ${line} | jshon -n object   \
  -s fwstatus -i name           \
  -s "${fwstatus}" -i full_text \
  -s "#${fwcol}" -i color      \
  -s center -i align            \
  -n false -i urgent            \
  -n true -i separator          \
  -n 9 -i separator_block_width \
  -i ${1})        
 
  return 0  
}

#
# function to get any reminders from the calcurse managed calander files
# basically just cat files created by our calcurse scripts
getReminders()
{
  # argument is mandatory
  [[ -z ${1} ]] && return 11
    
  # variables
  local col=${col_caution}

  # set text color based on the number in the text file
  [[ $(cat /tmp/reminders/reminder.txt) -le 2 ]] && col=${col_warning}
  [[ $(cat /tmp/reminders/reminder.txt) -ge 6 ]] && col=${col_normal}  
  
  # build the JSON object
  line=$(echo ${line} | jshon -n object   \
  -s reminder -i name           \
  -s "Rem: ($(cat /tmp/reminders/reminder.txt)d)" -i full_text      \
  -s Rem -i short_text          \
  -s "#${col}" -i color         \
  -s center -i align            \
  -n false -i urgent            \
  -n true -i separator          \
  -n 9 -i separator_block_width \
  -i ${1})  

  return 0
}

#
# function to get the current song title if ncmpcpp is running
getCurrentSong()
{
  # argument is mandatory
  [[ -z ${1} ]] && return 11
  
  # build the JSON object
  line=$(echo ${line} | jshon -n object   \
  -s songtitle -i name           \
  -s "$(ncmpcpp --now-playing)" -i full_text \
  -s "$(ncmpcpp --now-playing %t)" -i short_text \
  -s "#${col_nowplaying}" -i color   \
  -s center -i align            \
  -n false -i urgent            \
  -n true -i separator          \
  -n 9 -i separator_block_width \
  -i ${1})    
}

#
# function to check the input line for a mouse click we want to process
checkMouseClick()
{
    
  # variables
  local clickname
  
  # parse the input click and save the name of the clicked part of the bar
  clickname=$(echo ${click} | jshon -e name -u)

  # do whatever we want with the name
  case ${clickname} in
    time)       /usr/bin/myles_apps/start_calcurse.sh & ;;
    fwstatus)   /usr/bin/startoptions & ;;
    reminder)   /usr/bin/myles_apps/start_calcurse.sh & ;;
    volume)     /usr/bin/myles_apps/start_alsa_mixer.sh & ;;
    songtitle)  [[ $(echo ${click} | jshon -e button -u) == 1 ]]  \
                && ncmpcpp toggle                                 \
                || /usr/bin/myles_apps/start_music_player.sh &  ;;
    weather)
      if [[ $(cat /tmp/myles_weather/alert_level.txt) -gt 0 ]]; then
        [[ -e /tmp/myles_weather/long_sum.txt ]] && xterm -fn 7x13 -T 'Weather Alert' -geometry 70x50 -e "less -S -P 'q\:Quit j\:Scroll Down k\:Scroll Up g\:Top G\:Bottom  h\:Help %lB/%L %pB\% %t' /tmp/myles_weather/long_sum.txt" &
      else
        [[ -e /tmp/myles_weather/current_cond.txt ]] && xterm -fn 7x13 -T 'Current Weather Conditions' -geometry 75x20 -e "less -S -P 'q\:Quit j\:Scroll Down k\:Scroll Up g\:Top G\:Bottom  h\:Help %lB/%L %pB\% %t' /tmp/myles_weather/current_cond.txt" &           
      fi
      ;;
    *)  return 0 ;;
  esac
  
  return 0
}

############################### Main Script ###################################

#
# program constants
readonly col_green=00ff00
readonly col_cyan=00ffff
readonly col_red=ff0000
readonly col_yellow=ffff00
readonly col_white=ffffff
readonly col_dk_grey=585858
readonly col_bar_text=adbece 

readonly col_normal="${col_bar_text}"
readonly col_shadow="${col_dk_grey}"
readonly col_fullup="${col_green}"
readonly col_partup="${col_cyan}"
readonly col_caution="${col_yellow}"
readonly col_warning="${col_red}"
readonly col_nowplaying="${col_green}"

#
# program variables
xs=           # listing of the output from xset-q
havejshon=    # empty if jshon is not found on the system
comma=''      # need a comma before all lines after the first one that we process
line=         # JSON object as sent by i3status


# find out if we have the JSON parser, if not just pass on the lines without processing
# ignore any mouse click input
[[ -n $(which jshon 2>/dev/null) ]] && havejshon='found'
readonly havejshon


# We need to send the first 2 lines from this part of the script so that i3bar will send click
# events back to STDIN of this script
echo '{"version":1, "click_events": true }'
echo '['

# Start i3status and throw out the first 2 lines.  Run the while loop in a parallel child 
# process (the & at the end after the done)
#
# --config ~/.config/i3status/config_bar_1 is not required.  If you don't provide a config
# i3status will use the default config.  If you want a custom config change the path and 
# name to point to yours.  We use it because we have two bars and each has its own config.
#
# i3status --config ~/.config/i3status/config_bar_1  | (read line && read line && while :

i3status --config ~/.i3/status | (read line && read line && while :
do
  read -r line
  
  if [[ -n ${havejshon} ]]; then
    line=$(echo ${line#,})    # strip out leading comma if it exists
    
    ############   Call custom functions here
    # To inject our text it is simpler to work from right to left which makes keeping
    # track of the index values easier.   
    
    # Need xset to determine the key state. If not present skip this code block.
    # Place the call to xset here so we only have to do it once.  Caps and num
    # lock are odd, for the bar display we want them to appear in one block, but
    # they may show in different colors so they need to be processed separately.
    # Don't use a separator between so that they appear to be in one block.
    # Add the following lines to your ~./i3/config file to force i3status to update
    # immediately instead of waiting for the next interval to timeout:
    #
    #   bindsym Caps_Lock exec --no-startup-id killall -USR1 i3status
    #   bindsym --release Caps_Lock exec --no-startup-id killall -USR1 i3status
    #   bindsym Num_Lock exec --no-startup-id killall -USR1 i3status
    #   bindsym --release Num_Lock exec --no-startup-id killall -USR1 i3status
    # 
    if [[ -n $(which xset 2>/dev/null) ]]; then
      xs=$(xset -q)
      getNumLockState 1
      getCapLockState 1
    fi
    
    #
    # get the firewall status
    if [[ -e /usr/bin/myles_apps/fwsetup/fw_conf.txt ]]; then
      getFireWallStatus 1
    fi
    
    #
    # get the weather alert or temp/pressure info
    if [[ -e ~/Utilities/weather/getWeatherData.sh ]]; then
      getWeatherInfo 1
    fi 
    
    #
    # get or create then get the reminder text from our calcurse script
    if [[ -e ~/.calcurse/scripts/reminder.sh ]]; then
      [[ ! -e /tmp/reminders/reminder.txt ]] && ${HOME}/.calcurse/scripts/reminder.sh
      [[ -e /tmp/reminders/reminder.txt ]] && getReminders 0
    fi
    
    #
    # if mpd is running use ncmpcpp to get the name of the song if one is playing
    if [[ -n $(ps -e | grep 'mpd' 2>/dev/null) ]]; then
      [[ -n $(ncmpcpp --now-playing) ]] && getCurrentSong 0
    fi
    
    ############   Custom functions end here     
  
    # put back the comma we removed at the top, first line we process has none,
    # after that they all do   
    echo "${comma}"
    comma=','  
  fi

  # send the line on to be displayed
  echo "${line}" || exit 1
  
done) &


# Back to our primary script, start a loop to read input from STDIN, which
# should be the mouse clicks.
while read -r click
do
  if [[ -n ${havejshon} ]]; then
    click=$(echo ${click#,})    # strip out leading comma if it exists
    checkMouseClick
  fi
done



