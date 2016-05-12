#!/bin/bash
. xkb-reconfigure
. $HOME/.xrandrrc
xset m 1/1 0
xset fp+ ~/.fonts
xset fp rehash
[[ -f ~/.Xdefaults ]] && xrdb -remove 'urxvt*' && xrdb -merge ~/.Xdefaults
keynav &
parcellite &
exec dbus-launch i3
