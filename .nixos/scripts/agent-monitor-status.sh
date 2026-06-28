#!/usr/bin/env bash
# agent-monitor-status — emits a single line of JSON for the noctalia
# CustomButton widget describing the state of running coding-agent sessions.
#
# Output schema (consumed by noctalia's CustomButton parseJson):
#   {"text":"...", "icon":"...", "tooltip":"...", "color":"primary|secondary|tertiary|error|none"}
#
# When agent-monitor's HTTP API is unreachable (i.e. you haven't started
# `agent-monitor --headless`), it prints {"text":""} so the widget collapses
# and shows nothing.

API="${AGENT_MONITOR_API:-http://127.0.0.1:7654}"

# Empty text => widget collapses (see textCollapse in the noctalia config).
hide() { printf '{"text":""}\n'; exit 0; }

# Fetch status; bail to hidden on any failure or timeout.
json="$(curl -fsS --max-time 1 "${API}/status?recent=1" 2>/dev/null)" || hide
[ -n "$json" ] || hide

# Shape the widget JSON. The status JSON is passed as argv[1] (NOT stdin), so
# there's no conflict with how python is invoked.
python3 -c '
import sys, json

try:
    d = json.loads(sys.argv[1])
except Exception:
    print("{\"text\":\"\"}")
    sys.exit(0)

c = d.get("counts", {}) or {}
waiting = int(c.get("waiting", 0))
active  = int(c.get("active", 0))
idle    = int(c.get("idle", 0))
total   = int(c.get("total", 0))
sessions = d.get("sessions", []) or []

# Nothing to show -> hide the widget entirely.
if total == 0:
    print("{\"text\":\"\"}")
    sys.exit(0)

def short(s, n=70):
    s = (s or "").replace("\n", " ").strip()
    return s if len(s) <= n else s[: n - 1] + "\u2026"

GLYPH = {"opencode": "OC", "copilot": "CP"}
order = {"waiting": 0, "active": 1, "idle": 2, "stale": 3, "ended": 4}
lines = []
for s in sorted(sessions, key=lambda s: order.get(s.get("state"), 9)):
    st  = s.get("state", "?")
    src = GLYPH.get(s.get("source"), "?")
    title = short(s.get("title") or s.get("id") or "session", 48)
    if st == "waiting":
        w = s.get("waiting") or {}
        q = short(w.get("prompt") or "needs your input", 80)
        lines.append("\u23f3 [%s] %s\n     \u2192 %s" % (src, title, q))
    elif st == "active":
        act = short(s.get("currentAction") or "working", 50)
        lines.append("\u25cf [%s] %s \u2014 %s" % (src, title, act))
    elif st == "idle":
        lines.append("\u25cb [%s] %s (idle)" % (src, title))
    # stale/ended omitted to keep the tooltip focused on whats live

tooltip = "agent-monitor\n" + "\n".join(lines) if lines else "agent-monitor"

if waiting > 0:
    out = {"text": "%d\u2757" % waiting, "icon": "hourglass", "color": "error"}
elif active > 0:
    out = {"text": str(active), "icon": "robot", "color": "tertiary"}
else:
    out = {"text": str(idle if idle else total), "icon": "robot", "color": "none"}

out["tooltip"] = tooltip
print(json.dumps(out))
' "$json"
