#!/bin/sh
# yabai-focus-ghostty -- cmd+2 handler for Ghostty (special-cased).
#
#   * If Ghostty isn't the focused app -> focus its window on the BUILT-IN
#     laptop display (so cmd+2 always lands on the laptop terminal first).
#   * If Ghostty is already focused    -> cycle to the next Ghostty window
#     (by window id, wrapping) -- lets cmd+2 walk through all terminals.
#   * If Ghostty isn't running         -> launch it.
#
# LAPTOP_UUID is the built-in display's yabai UUID (from `yabai -m query
# --displays`); update it if the machine's built-in display changes.
YABAI=/opt/homebrew/bin/yabai; JQ=/usr/bin/jq
LAPTOP_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

Q=$("$YABAI" -m query --windows 2>/dev/null)
ids=$(printf '%s' "$Q" | "$JQ" -r '[.[] | select(.app == "Ghostty")] | sort_by(.id) | .[].id')
[ -z "$ids" ] && { /usr/bin/open -b com.mitchellh.ghostty; exit 0; }

foc=$("$YABAI" -m query --windows --window 2>/dev/null)
focapp=$(printf '%s' "$foc" | "$JQ" -r '.app // ""')
focid=$(printf '%s' "$foc" | "$JQ" -r '.id // 0')

if [ "$focapp" = "Ghostty" ]; then
  # cycle to the window after the focused one (wrap to first)
  target=$(printf '%s\n' "$ids" | awk -v c="$focid" 'NR==1{first=$0} {if(prev==c){print;f=1;exit} prev=$0} END{if(!f)print first}')
else
  # focus the Ghostty window on the built-in laptop display (fallback: first)
  lapidx=$("$YABAI" -m query --displays 2>/dev/null | "$JQ" -r --arg u "$LAPTOP_UUID" '.[] | select(.uuid == $u) | .index')
  target=$(printf '%s' "$Q" | "$JQ" -r --argjson d "${lapidx:-0}" '[.[] | select(.app == "Ghostty" and .display == $d)] | max_by(.frame.w * .frame.h) | .id // empty')
  [ -z "$target" ] && target=$(printf '%s\n' "$ids" | head -1)
fi

"$YABAI" -m window --focus "$target" 2>/dev/null || /usr/bin/open -b com.mitchellh.ghostty
