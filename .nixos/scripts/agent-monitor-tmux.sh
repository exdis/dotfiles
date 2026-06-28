#!/usr/bin/env bash
# agent-monitor-tmux — emits a tmux status-line segment describing the state of
# running coding-agent sessions (opencode / copilot), mirroring the noctalia bar
# widget's icons and color coding.
#
#   * (nothing)         when the API is unreachable (you haven't started
#                       `agent-monitor --headless`) or no sessions are live
#   * red    󰔝 N        when N sessions are blocked waiting on you
#   * accent 󰚩 N        when N sessions are actively working
#   * dim    󰚩 N        when only idle sessions remain
#
# Designed to be called from tmux status-right via #(...). Output is a single
# line containing tmux #[...] style directives; empty when there's nothing to
# show. Colors map to the alabaster palette used in tmux.conf:
#   waiting -> colour204 (red, ~#e06c75 / mError)
#   active  -> colour176 (magenta, ~#c678dd / mTertiary, == accent4)
#   idle    -> colour245 (dim grey)

API="${AGENT_MONITOR_API:-http://127.0.0.1:7654}"

# Nothing to show: print empty and exit (tmux renders nothing).
nothing() { exit 0; }

json="$(curl -fsS --max-time 1 "${API}/status?recent=1" 2>/dev/null)" || nothing
[ -n "$json" ] || nothing

# Shape the tmux segment. The status JSON is passed as argv[1] (not stdin).
python3 -c '
import sys, json

try:
    d = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)

c = d.get("counts", {}) or {}
waiting = int(c.get("waiting", 0))
active  = int(c.get("active", 0))
idle    = int(c.get("idle", 0))
total   = int(c.get("total", 0))

if total == 0:
    sys.exit(0)

# Nerd Font glyphs (FiraCode Nerd Font): timer-sand + robot.
GLYPH_WAIT = "\U000f051d"   # nf-md-timer_sand  󰔝
GLYPH_BOT  = "\U000f06a9"   # nf-md-robot       󰚩

# tmux colours (match tmux.conf alabaster palette + noctalia semantics).
RED   = "colour204"
ACCT  = "colour176"
DIM   = "colour245"
RESET = "colour252"

if waiting > 0:
    seg = "#[fg=%s,bold]%s %d#[fg=%s,nobold]" % (RED, GLYPH_WAIT, waiting, RESET)
elif active > 0:
    seg = "#[fg=%s]%s %d#[fg=%s]" % (ACCT, GLYPH_BOT, active, RESET)
else:
    n = idle if idle else total
    seg = "#[fg=%s]%s %d#[fg=%s]" % (DIM, GLYPH_BOT, n, RESET)

# Trailing space keeps the indicator from merging into the next status segment.
# It is part of the segment output, so nothing is printed (no stray space) when
# there is nothing to show.
sys.stdout.write(seg + " ")
' "$json"
