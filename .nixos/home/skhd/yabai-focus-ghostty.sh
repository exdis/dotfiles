#!/bin/sh
# yabai-focus-ghostty [external] -- cmd+2 / ctrl+cmd+2 handler for Ghostty.
#
#   (no arg)   focus Ghostty on the built-in LAPTOP display; repeat = cycle
#              through the laptop Ghostty windows.
#   external   focus Ghostty on the OTHER (external) monitors; repeat = cycle
#              through those.
# If the chosen group has no window, fall back to any Ghostty window; if
# Ghostty isn't running, launch it.
#
# Kept to 2 yabai queries + 1 jq for speed. LAPTOP_UUID is the built-in
# display's yabai UUID (from `yabai -m query --displays`); update if it changes.
YABAI=/opt/homebrew/bin/yabai; JQ=/usr/bin/jq
LAPTOP_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"
mode="$1"

wins=$("$YABAI" -m query --windows 2>/dev/null)
[ -z "$wins" ] && { /usr/bin/open -b com.mitchellh.ghostty; exit 0; }
disps=$("$YABAI" -m query --displays 2>/dev/null)

# One jq does it all: pick the Ghostty window group (laptop vs external), then
# either cycle to the next window in that group (if a group window is focused)
# or jump to the group's largest window.
target=$(printf '%s' "$wins" | "$JQ" -r --argjson disps "$disps" --arg lap "$LAPTOP_UUID" --arg mode "$mode" '
  ($disps[] | select(.uuid == $lap) | .index) as $lapidx
  | [ .[] | select(.app == "Ghostty") ] as $all
  | ( if $mode == "external" then [ $all[] | select(.display != $lapidx) ]
                             else [ $all[] | select(.display == $lapidx) ] end ) as $g0
  | ( if ($g0 | length) > 0 then $g0 else $all end ) as $grp
  | ( $grp | sort_by(.id) | map(.id) ) as $ids
  | ( [ $all[] | select(.["has-focus"] == true) | .id ][0] ) as $foc
  | ( if ($foc != null) and (($ids | index($foc)) != null)
        then $ids[ (($ids | index($foc)) + 1) % ($ids | length) ]
        else ($grp | max_by(.frame.w * .frame.h) | .id) end ) // empty
')

[ -n "$target" ] && "$YABAI" -m window --focus "$target" 2>/dev/null
