#!/bin/sh
# yabai-focus-ghostty-external -- ctrl+cmd+2 handler for Ghostty.
#
# Like yabai-focus-ghostty.sh but for the OTHER monitors: focus the Ghostty
# window that is NOT on the built-in laptop display.
#   * If no external Ghostty window is focused -> focus the (largest) Ghostty
#     window on a non-laptop display.
#   * If one already is             -> cycle to the next external Ghostty window.
#   * If Ghostty has no external window -> focus any Ghostty window (fallback).
#   * If Ghostty isn't running        -> launch it.
#
# LAPTOP_UUID is the built-in display's yabai UUID; keep in sync with
# yabai-focus-ghostty.sh.
YABAI=/opt/homebrew/bin/yabai; JQ=/usr/bin/jq
LAPTOP_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

Q=$("$YABAI" -m query --windows 2>/dev/null)
all=$(printf '%s' "$Q" | "$JQ" -r '[.[] | select(.app == "Ghostty")] | sort_by(.id) | .[].id')
[ -z "$all" ] && { /usr/bin/open -b com.mitchellh.ghostty; exit 0; }

lapidx=$("$YABAI" -m query --displays 2>/dev/null | "$JQ" -r --arg u "$LAPTOP_UUID" '.[] | select(.uuid == $u) | .index')
# Ghostty windows NOT on the laptop display, sorted by id
extids=$(printf '%s' "$Q" | "$JQ" -r --argjson d "${lapidx:-0}" '[.[] | select(.app == "Ghostty" and .display != $d)] | sort_by(.id) | .[].id')
[ -z "$extids" ] && extids="$all"   # no external window -> fall back to any

foc=$("$YABAI" -m query --windows --window 2>/dev/null)
focapp=$(printf '%s' "$foc" | "$JQ" -r '.app // ""')
focid=$(printf '%s' "$foc" | "$JQ" -r '.id // 0')

if [ "$focapp" = "Ghostty" ] && printf '%s\n' "$extids" | grep -qx "$focid"; then
  # currently on an external Ghostty window -> cycle to the next external one
  target=$(printf '%s\n' "$extids" | awk -v c="$focid" 'NR==1{first=$0} {if(prev==c){print;f=1;exit} prev=$0} END{if(!f)print first}')
else
  # jump to the largest external Ghostty window
  target=$(printf '%s' "$Q" | "$JQ" -r --argjson d "${lapidx:-0}" '[.[] | select(.app == "Ghostty" and .display != $d)] | max_by(.frame.w * .frame.h) | .id // empty')
  [ -z "$target" ] && target=$(printf '%s\n' "$extids" | head -1)
fi

"$YABAI" -m window --focus "$target" 2>/dev/null || /usr/bin/open -b com.mitchellh.ghostty
