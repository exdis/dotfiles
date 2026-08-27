#!/bin/sh
# yabai-focus <yabai-app-name> <bundle-id> [open] -- focus an app's MAIN
# window, reliably across Spaces/displays. Bound to cmd+N in
# ~/.config/skhd/skhdrc.
#
# A short-lived process spawned by skhd cannot focus a window on a background
# Space itself (it only changes the CGS front-process, which repaints the menu
# bar but never truly activates the app), so we ask yabai -- a persistent daemon
# holding a real WindowServer connection -- to do it. Of the app's windows we
# take the largest by area, which is what keeps cmd+8 on Zen's real browser
# window instead of its much smaller Picture-in-Picture video popup (yabai does
# list the PiP as an ordinary AXStandardWindow, so it IS a candidate here).
#
# Zen/Firefox caveat, and the reason for the AX fallback below. Firefox only
# publishes a window to the Accessibility API while that window's Space is
# VISIBLE. yabai enumerates windows once at startup and never retries, so if
# Zen's main window sits on a background Space at that moment yabai caches a
# record with has-ax-reference=false and `yabai -m window --focus <id>` fails
# forever after ("could not locate window with the specified id"). That is easy
# to hit because the yabai agent is kickstarted on every `darwin-rebuild switch`
# (see home.activation.reloadSkhd in home/darwin.nix). We would then fall back
# to `open -b`, and LaunchServices activates whatever Zen's key window is -- the
# PiP, which is always-on-top and lives on the CURRENT Space -- so the Space
# never switches and cmd+8 looks dead whenever a video popup is open.
#
# yabai still knows the window's Space even with no AX reference, so recover
# without restarting anything: switch to that Space (pure CGS, needs no AX),
# which makes Firefox publish the window, then raise it over the PiP via AX.
#
# If the app isn't running, or nothing above worked, fall back to `open -b`,
# which uses LaunchServices to activate + switch Space correctly.
#
# Pass "open" as a 3rd arg to SKIP straight to `open -b`: some apps CRASH on
# yabai's synthetic focus events (notably recent Microsoft Teams), so those must
# be activated via LaunchServices only.
app="$1"; bundle="$2"; method="$3"
YABAI=/opt/homebrew/bin/yabai; JQ=/usr/bin/jq

# "<window-id> <has-ax-reference> <space-index>" for the app's largest window;
# empty if yabai knows no window for it. Matched case-insensitively because
# yabai reports the process name ("zen") while the AX reference is missing and
# the app name ("Zen") once it has one.
query_window() {
  "$YABAI" -m query --windows 2>/dev/null | "$JQ" -r --arg a "$app" '
    ($a | ascii_downcase) as $al
    | [ .[] | select((.app | ascii_downcase) == $al) ]
    | max_by(.frame.w * .frame.h)
    | if . == null then empty
      else "\(.id) \(.["has-ax-reference"]) \(.space)" end'
}

# Activate the app and raise its largest AX window. Mirrors the max_by(area)
# pick above rather than matching the PiP by title, which is localised. Only
# works once the window's Space is visible (see the Firefox caveat above).
raise_largest_ax_window() {
  /usr/bin/osascript - "$app" >/dev/null 2>&1 <<'APPLESCRIPT'
on run argv
  tell application "System Events" to tell process (item 1 of argv)
    set frontmost to true
    set best to missing value
    set bestArea to -1
    repeat with w in windows
      try
        set {ww, hh} to size of w
        if (ww * hh) > bestArea then
          set bestArea to ww * hh
          set best to w
        end if
      end try
    end repeat
    if best is missing value then error "no accessible windows"
    perform action "AXRaise" of best
    set value of attribute "AXMain" of best to true
  end tell
end run
APPLESCRIPT
}

focus_via_yabai() {
  win=$(query_window)
  [ -n "$win" ] || return 1
  id=${win%% *}; rest=${win#* }
  hasax=${rest%% *}; space=${rest#* }

  # Fast path: yabai has a usable AX reference, so let it do everything.
  if [ "$hasax" = "true" ] && "$YABAI" -m window --focus "$id" 2>/dev/null; then
    return 0
  fi

  # Recovery path: reveal the window's Space so the app publishes it to AX,
  # then raise it ourselves.
  "$YABAI" -m space --focus "$space" 2>/dev/null || return 1
  raise_largest_ax_window
}

if [ "$method" != "open" ] && focus_via_yabai; then
  exit 0
fi
/usr/bin/open -b "$bundle"
