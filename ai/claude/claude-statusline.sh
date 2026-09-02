#!/bin/bash
# Claude Code status line: show the conversation name in the footer and the
# terminal tab/pane title. Prefers an explicit session name (--name / /rename),
# falling back to the auto-generated ai-title from the transcript.
input=$(cat)

bold=$'\033[1m'
dim=$'\033[2m'
cyan=$'\033[36m'
green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[31m'
reset=$'\033[0m'

transcript=$(echo "$input" | jq -r '.transcript_path // empty')
[ -f "$transcript" ] || transcript=""

cwd=$(echo "$input" | jq -r '.cwd // empty')

name=$(echo "$input" | jq -r '.session_name // empty')
if [ -z "$name" ] && [ -n "$transcript" ]; then
  name=$(jq -r 'select(.type=="ai-title") | .aiTitle' "$transcript" 2>/dev/null | tail -1)
fi
[ -z "$name" ] && name="claude"

# Wall-clock time of the last user-submitted turn (not tool results,
# interruptions, or other synthetic transcript entries) — absolute, not
# relative, since a relative "X ago" would go stale between statusline
# refreshes.
[ -n "$transcript" ] && age=$(jq -rn '
  [inputs | select(.type=="user" and (.message.content|type)=="string") | .timestamp] | last as $ts
  | if $ts == null then empty else
      ($ts | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601 | localtime) as $lt
      | (now | localtime) as $today
      | if $lt[0:3] == $today[0:3] then $lt | strftime("%H:%M")
        else $lt | strftime("%b %d %H:%M") end
    end' "$transcript" 2>/dev/null)

model=$(echo "$input" | jq -r '.model.display_name // empty')

pct=$(echo "$input" | jq -r '
  .context_window as $c
  | (($c.total_input_tokens // 0)) as $used
  | if $used > 0 then (($c.used_percentage // (($used / (($c.context_window_size // 200000)) * 100))) | floor) else empty end')
ctx=$(echo "$input" | jq -r '
  .context_window as $c
  | (($c.total_input_tokens // 0)) as $used
  | if $used > 0 then
      (($c.context_window_size // 200000)) as $max
      | (($c.used_percentage // (($used / $max) * 100)) | floor) as $pct
      | "\($used / 1000 | floor)k/\($max / 1000 | floor)k (\($pct)%)"
    else empty end')
if [ -n "$ctx" ]; then
  if [ "$pct" -ge 80 ]; then ctx="$red$ctx$reset"
  elif [ "$pct" -ge 50 ]; then ctx="$yellow$ctx$reset"
  else ctx="$green$ctx$reset"
  fi
fi

cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ -n "$cost_usd" ] && cost=$(printf '$%.2f' "$cost_usd")

session_id=$(echo "$input" | jq -r '.session_id // empty')
session_code=${session_id: -8}

# Clickable link to this conversation's agent-sessions view (assumes it has
# been synced into the index already; syncing is a separate concern).
link_open="" link_close=""
if [ -n "$session_id" ]; then
  link_open=$'\033]8;;http://127.0.0.1:7118/session/claude:'"$session_id"$'\033\\'
  link_close=$'\033]8;;\033\\'
fi

# Current wormhole project/task for the session's directory, e.g. "api-go" or
# "api-go:some-branch" when the project is checked out as a task worktree.
task=""
if [ -n "$cwd" ] && command -v wormhole >/dev/null 2>&1; then
  task=$(cd "$cwd" 2>/dev/null && timeout 1 wormhole project show -o json 2>/dev/null \
    | jq -r 'if .branch then "\(.name):\(.branch)" else .name end' 2>/dev/null)
fi

{ printf '\033]0;%s\007' "$name" > /dev/tty; } 2>/dev/null   # tab/pane title

# wormhole task, then session identity, then run stats — each stat its own
# "│"-separated field so the busiest/most-variable info sits at the end.
identity="$bold$link_open$name$link_close$reset  $dim#$session_code$reset"

line=""
[ -n "$task" ] && line="$cyan$task$reset | "
line="$line$identity"

[ -n "$model" ] && line="$line │ $dim$model$reset"
[ -n "$cost" ] && line="$line │ $dim$cost$reset"
[ -n "$ctx" ] && line="$line │ $ctx"
[ -n "$age" ] && line="$line │ $dim$age$reset"

echo "$line"
