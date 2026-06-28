-- agent-monitor bar widget for noctalia v5
--
-- Polls the agent-monitor HTTP status API and renders a compact, color-coded
-- indicator of coding-agent sessions (opencode / copilot):
--   * hidden            when the API is unreachable (you haven't started
--                       `agent-monitor --headless`) or no sessions are live
--   * red "N!" hourglass when N sessions are blocked waiting on you
--   * accent "N" robot   when N sessions are actively working
--   * dim "N" robot      when only idle sessions remain
--
-- Left-click opens the full TUI in a terminal.
--
-- API bindings used (noctalia v5):
--   noctalia.http({url=...}, cb)   -> cb({ok, status, body})
--   noctalia.json.decode(str)      -> table
--   noctalia.runAsync(cmd)         -> run a detached shell command
--   noctalia.setUpdateInterval(ms) -> set the poll cadence
--   barWidget.setText/setGlyph/setColor/setGlyphColor/setTooltip/setVisible

-- Read a declared plugin setting (barWidget.getConfig(key) -> value | nil),
-- falling back to a default when unset.
local function cfg(key, default)
  local ok, v = pcall(barWidget.getConfig, key)
  if ok and v ~= nil then
    return v
  end
  return default
end

local API = cfg("api_url", "http://127.0.0.1:7654")
local TERMINAL = cfg("terminal", "ghostty")
local TUI_COMMAND = cfg("tui_command", "/home/exdis/dev/agent-monitor/bin/agent-monitor")
local INTERVAL = tonumber(cfg("interval_ms", 2000)) or 2000

-- Poll cadence.
noctalia.setUpdateInterval(INTERVAL)

local function hide()
  barWidget.setVisible(false)
  barWidget.setText("")
  barWidget.clearTooltip()
end

local function trunc(s, n)
  s = tostring(s or "")
  s = s:gsub("[\r\n]+", " ")
  if #s > n then
    return s:sub(1, n - 1) .. "\u{2026}"
  end
  return s
end

local SRC = { opencode = "OC", copilot = "CP" }
local ORDER = { waiting = 0, active = 1, idle = 2, stale = 3, ended = 4 }

local function render(body)
  local ok, data = pcall(noctalia.json.decode, body)
  if not ok or type(data) ~= "table" then
    hide()
    return
  end

  local counts = data.counts or {}
  local waiting = tonumber(counts.waiting) or 0
  local active = tonumber(counts.active) or 0
  local idle = tonumber(counts.idle) or 0
  local total = tonumber(counts.total) or 0

  if total == 0 then
    hide()
    return
  end

  -- Build a focused tooltip (waiting first, then active, then idle).
  local sessions = data.sessions or {}
  table.sort(sessions, function(a, b)
    return (ORDER[a.state] or 9) < (ORDER[b.state] or 9)
  end)

  local lines = { "agent-monitor" }
  for _, s in ipairs(sessions) do
    local src = SRC[s.source] or "?"
    local title = trunc(s.title ~= "" and s.title or s.id, 46)
    if s.state == "waiting" then
      local w = s.waiting or {}
      lines[#lines + 1] = string.format("\u{23F3} [%s] %s", src, title)
      lines[#lines + 1] = string.format("      \u{2192} %s", trunc(w.prompt or "needs your input", 60))
    elseif s.state == "active" then
      lines[#lines + 1] = string.format("\u{25CF} [%s] %s \u{2014} %s", src, title,
        trunc(s.currentAction or "working", 44))
    elseif s.state == "idle" then
      lines[#lines + 1] = string.format("\u{25CB} [%s] %s (idle)", src, title)
    end
  end
  barWidget.setTooltip(table.concat(lines, "\n"))

  barWidget.setVisible(true)
  if waiting > 0 then
    barWidget.setText(tostring(waiting) .. "\u{2757}") -- N + heavy exclamation
    barWidget.setGlyph("hourglass")
    barWidget.setColor("error")
    barWidget.setGlyphColor("error")
  elseif active > 0 then
    barWidget.setText(tostring(active))
    barWidget.setGlyph("robot")
    barWidget.setColor("tertiary")
    barWidget.setGlyphColor("tertiary")
  else
    barWidget.setText(tostring(idle > 0 and idle or total))
    barWidget.setGlyph("robot")
    barWidget.setColor("on_surface")
    barWidget.setGlyphColor("on_surface")
  end
end

-- Periodic update entry point (called by noctalia on the poll timer).
function update()
  noctalia.http({ url = API .. "/status?recent=1" }, function(res)
    if not res or not res.ok or (res.status and res.status >= 400) then
      hide()
      return
    end
    render(res.body or "")
  end)
end

-- Left-click opens the TUI. agent-monitor (the binary) launches the dashboard;
-- it shares the same on-disk sources, so it attaches to whatever is running.
function onClick()
  noctalia.runAsync(string.format("%s -e %s", TERMINAL, TUI_COMMAND))
end
