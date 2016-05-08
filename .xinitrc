#!/bin/bash
# setxkbmap "us,ru" ",winkeys" "grp:alt_shift_toggle"
# setxkbmap -option "shift:both_capslock"
# xmodmap -e 'clear Lock'
# xmodmap -e 'keycode 0x42=Escape'
xkbcomp $HOME/.config/xkb/my $DISPLAY
. $HOME/.xrandrrc
xinput --set-prop 11 255 1.5
xset fp+ ~/.fonts
xset fp rehash
[[ -f ~/.Xdefaults ]] && xrdb -remove 'urxvt*' && xrdb -merge ~/.Xdefaults
keynav &
parcellite &
sudo $HOME/dev/golang/shift-shift/shift-shift -quiet > /dev/null &
exec i3
