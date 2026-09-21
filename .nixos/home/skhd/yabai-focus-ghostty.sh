#!/bin/sh
# yabai-focus-ghostty [external] -- cmd+2 / cmd+7 handler for Ghostty.
#
#   (no arg)   focus Ghostty on the built-in LAPTOP display; repeat = cycle
#              through the laptop Ghostty windows.
#   external   focus Ghostty on the OTHER (external) monitors; repeat = cycle
#              through those.
# If the chosen group has no window, fall back to any Ghostty window; if
# Ghostty isn't running, launch it.
#
# Fast path uses 2 yabai queries + 1 jq. LAPTOP_UUID is the built-in
# display's yabai UUID (from `yabai -m query --displays`); update if it changes.
YABAI=/opt/homebrew/bin/yabai; JQ=/usr/bin/jq
LAPTOP_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"
mode="$1"

wins=$("$YABAI" -m query --windows 2>/dev/null)
[ -z "$wins" ] && { /usr/bin/open -b com.mitchellh.ghostty; exit 0; }
disps=$("$YABAI" -m query --displays 2>/dev/null)
[ -z "$disps" ] && { /usr/bin/open -b com.mitchellh.ghostty; exit 0; }

# One jq does it all: pick the Ghostty window group (laptop vs external), then
# either cycle to the next window in that group (if a group window is focused)
# or jump to the group's largest window. App name matched case-insensitively
# (yabai may report "Ghostty" or "ghostty" depending on version/OS).
target=$(printf '%s' "$wins" | "$JQ" -r --argjson disps "$disps" --arg lap "$LAPTOP_UUID" --arg mode "$mode" '
  ([ $disps[] | select(.uuid == $lap) | .index ][0]) as $lapidx
  | [ .[] | select((.app | ascii_downcase) == "ghostty") ] as $all
  | ( if $mode == "external" then [ $all[] | select(.display != $lapidx) ]
                             else [ $all[] | select(.display == $lapidx) ] end ) as $g0
  | ( if ($g0 | length) > 0 then $g0 else $all end ) as $grp
  | ( $grp | sort_by(.id) | map(.id) ) as $ids
  | ( [ $all[] | select(.["has-focus"] == true) | .id ][0] ) as $foc
  | ( if ($foc != null) and (($ids | index($foc)) != null)
         then $ids[ (($ids | index($foc)) + 1) % ($ids | length) ]
         else ($grp | max_by(.frame.w * .frame.h) | .id) end ) as $id
  | $grp[] | select(.id == $id)
  | [.id, .space, .frame.x, .frame.y, .frame.w, .frame.h] | @tsv
')

[ -z "$target" ] && { /usr/bin/open -b com.mitchellh.ghostty; exit 0; }
# The selected record contains only numeric fields.
set -f
# shellcheck disable=SC2086
set -- $target
"$YABAI" -m window --focus "$1" 2>/dev/null && exit 0

# Like Zen, Ghostty can have a cached window without a usable AX reference.
# Reveal its Space, then match its frame rather than raising an arbitrary
# Ghostty window (which could be on the other display).
"$YABAI" -m space --focus "$2" || exit 1
/usr/bin/osascript - "$3" "$4" "$5" "$6" <<'APPLESCRIPT'
on run argv
  set {targetX, targetY, targetWidth, targetHeight} to {item 1 of argv as real, item 2 of argv as real, item 3 of argv as real, item 4 of argv as real}
  tell application "System Events" to tell process "Ghostty"
    repeat with w in windows
      set {wx, wy} to position of w
      set {ww, wh} to size of w
      if (absValue(wx - targetX) of me < 2) and (absValue(wy - targetY) of me < 2) and (absValue(ww - targetWidth) of me < 2) and (absValue(wh - targetHeight) of me < 2) then
        set frontmost to true
        perform action "AXRaise" of w
        set value of attribute "AXMain" of w to true
        return
      end if
    end repeat
    error "Could not find the selected Ghostty window through Accessibility"
  end tell
end run

on absValue(n)
  if n < 0 then return -n
  return n
end absValue
APPLESCRIPT
