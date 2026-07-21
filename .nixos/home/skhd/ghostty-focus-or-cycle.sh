#!/bin/sh
# cmd+2 handler for skhd. If Ghostty is already the frontmost app, cycle to its
# next window (by synthesizing the private combo Ghostty binds to
# goto_window:next -- which reaches windows on other monitors). Otherwise just
# focus/launch Ghostty. lsappinfo gives the frontmost app without needing any
# Automation permission.
front="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | sed -n 's/.*"[^"]*"="\(.*\)"/\1/p')"
if [ "$front" = "Ghostty" ]; then
	/opt/homebrew/bin/skhd -k "cmd + ctrl + alt - 2"
else
	/usr/bin/osascript -e 'tell application "Ghostty" to activate'
fi
