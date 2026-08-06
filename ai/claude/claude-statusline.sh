#!/bin/bash
# Claude Code status line: show the conversation name in the footer and the
# terminal tab/pane title. Prefers an explicit session name (--name / /rename),
# falling back to the auto-generated ai-title from the transcript.
input=$(cat)

transcript=$(echo "$input" | jq -r '.transcript_path // empty')
[ -f "$transcript" ] || transcript=""

name=$(echo "$input" | jq -r '.session_name // empty')
if [ -z "$name" ] && [ -n "$transcript" ]; then
  name=$(jq -r 'select(.type=="ai-title") | .aiTitle' "$transcript" 2>/dev/null | tail -1)
fi
[ -z "$name" ] && name="claude"

# Age of the session, so that resuming an old one is visually obvious.
[ -n "$transcript" ] && age=$(head -50 "$transcript" | jq -rn '
  first(inputs | .timestamp // empty)
  | (sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) as $start
  | ((now - $start) / 60 | floor) as $m
  | if $m < 60 then empty
    elif $m < 1440 then "\($m / 60 | floor)h ago"
    else "\($m / 1440 | floor)d ago" end' 2>/dev/null)

model=$(echo "$input" | jq -r '.model.display_name // empty')

ctx=$(echo "$input" | jq -r '
  .context_window as $c
  | (($c.total_input_tokens // 0)) as $used
  | if $used > 0 then
      (($c.context_window_size // 200000)) as $max
      | (($c.used_percentage // (($used / $max) * 100)) | floor) as $pct
      | "\($used / 1000 | floor)k/\($max / 1000 | floor)k (\($pct)%)"
    else empty end')

cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ -n "$cost_usd" ] && cost=$(printf '$%.2f' "$cost_usd")

session_id=$(echo "$input" | jq -r '.session_id // empty')
session_code=${session_id: -8}

{ printf '\033]0;%s\007' "$name" > /dev/tty; } 2>/dev/null   # tab/pane title

line="$name"
[ -n "$model" ] && line="$line  ·  $model"
[ -n "$ctx" ] && line="$line  ·  $ctx"
[ -n "$cost" ] && line="$line  ·  $cost"
[ -n "$age" ] && line="$line  ·  $age"

cols=$(tput cols 2>/dev/null)
if [ -n "$cols" ] && [ -n "$session_code" ]; then
  pad=$((cols - ${#line} - ${#session_code} - 1))
  [ "$pad" -lt 1 ] && pad=1
  printf '%s%*s%s\n' "$line" "$pad" "" "$session_code"
else
  echo "$line  ·  $session_code"
fi
