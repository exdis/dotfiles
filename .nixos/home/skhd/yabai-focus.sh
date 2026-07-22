#!/bin/sh
# yabai-focus <yabai-app-name> <bundle-id> -- focus an app's MAIN window,
# reliably across Spaces/displays. Bound to cmd+N in ~/.config/skhd/skhdrc.
#
# We ask yabai (a persistent daemon holding a real WindowServer connection) to
# focus the app's largest window -- this crosses background Spaces and other
# displays, and picks the main window rather than e.g. Zen's floating PiP. A
# short-lived process spawned by skhd cannot do this itself (it only changes the
# CGS front-process, which repaints the menu bar but never truly activates the
# app). If yabai can't focus the window (some windows report can-move=false,
# e.g. Outlook) or the app isn't running, fall back to `open -b`, which uses
# LaunchServices to activate + switch Space correctly.
app="$1"; bundle="$2"
id=$(/opt/homebrew/bin/yabai -m query --windows 2>/dev/null \
  | /usr/bin/jq -r --arg a "$app" '[.[] | select(.app == $a)] | max_by(.frame.w * .frame.h) | .id // empty')
if [ -n "$id" ] && /opt/homebrew/bin/yabai -m window --focus "$id" 2>/dev/null; then
  exit 0
fi
/usr/bin/open -b "$bundle"
