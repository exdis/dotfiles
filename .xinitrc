#!/bin/bash
# setxkbmap "us,ru" ",winkeys" "grp:alt_shift_toggle"
# setxkbmap -option "shift:both_capslock"
# xmodmap -e 'clear Lock'
# xmodmap -e 'keycode 0x42=Escape'
xkbcomp $HOME/.config/xkb/my $DISPLAY
xrandr --auto --output VGA1 --left-of HDMI1
xinput --set-prop 11 255 1.5
[[ -f ~/.Xdefaults ]] && xrdb -remove 'urxvt*' && xrdb -merge ~/.Xdefaults
