#!/bin/bash
xrandr
xrandr --auto
xrandr --output DP1-1 --off
xrandr --output DP1-2 --off
. /home/.xkb-reconfigure
