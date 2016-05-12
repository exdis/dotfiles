#!/bin/bash
. $HOME/.xrandrrc
. $HOME/.xkb-reconfigure
xset m 1/1 0
xset fp+ ~/.fonts
xset fp rehash
[[ -f ~/.Xdefaults ]] && xrdb -remove 'urxvt*' && xrdb -merge ~/.Xdefaults
keynav &
parcellite &
dunst -config .dunstrc &
exec dbus-launch i3
