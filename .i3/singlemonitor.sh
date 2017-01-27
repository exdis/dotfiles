#!/bin/bash
xrandr
xrandr --output DP1-1 --off
xrandr --output DP1-2 --off
xrandr --auto
. /home/.xkb-reconfigure
