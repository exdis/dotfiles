#!/bin/zsh

MCABBER_NO=`cat /home/exdis/.mcabber/mcabber.state &>/dev/null|wc -l`

[[ "$MCABBER_NO" -gt "0" ]] && echo "$MCABBER_NO"

exit 0
