#!/bin/sh
# yabai-focus <yabai-app-name> <bundle-id> [open] -- focus an app's MAIN
# window, reliably across Spaces/displays. Bound to cmd+N in
# ~/.config/skhd/skhdrc.
#
# We ask yabai (a persistent daemon holding a real WindowServer connection) to
# focus the app's largest window -- this crosses background Spaces and other
# displays, and picks the main window rather than e.g. Zen's floating PiP. A
# short-lived process spawned by skhd cannot do this itself (it only changes the
# CGS front-process, which repaints the menu bar but never truly activates the
# app). If yabai can't focus the window (some windows report can-move=false,
# e.g. Outlook) or the app isn't running, fall back to `open -b`, which uses
# LaunchServices to activate + switch Space correctly.
#
# Pass "open" as a 3rd arg to SKIP yabai and go straight to `open -b`: some apps
# CRASH on yabai's synthetic focus events (notably recent Microsoft Teams), so
# those must be activated via LaunchServices only.
app="$1"; bundle="$2"; method="$3"
if [ "$method" != "open" ]; then
  id=$(/opt/homebrew/bin/yabai -m query --windows 2>/dev/null \
    | /usr/bin/jq -r --arg a "$app" '($a | ascii_downcase) as $al | [.[] | select((.app | ascii_downcase) == $al)] | max_by(.frame.w * .frame.h) | .id // empty')
  if [ -n "$id" ] && /opt/homebrew/bin/yabai -m window --focus "$id" 2>/dev/null; then
    exit 0
  fi
fi
/usr/bin/open -b "$bundle"
