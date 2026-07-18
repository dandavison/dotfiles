#!/bin/bash
# Claude Code status line: show the conversation name in the footer and the
# terminal tab/pane title. Prefers an explicit session name (--name / /rename),
# falling back to the auto-generated ai-title from the transcript.
input=$(cat)

name=$(echo "$input" | jq -r '.session_name // empty')
if [ -z "$name" ]; then
  transcript=$(echo "$input" | jq -r '.transcript_path // empty')
  if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    name=$(jq -r 'select(.type=="ai-title") | .aiTitle' "$transcript" 2>/dev/null | tail -1)
  fi
fi
[ -z "$name" ] && name="claude"

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

{ printf '\033]0;%s\007' "$name" > /dev/tty; } 2>/dev/null   # tab/pane title

line="$name"
[ -n "$model" ] && line="$line  ·  $model"
[ -n "$ctx" ] && line="$line  ·  $ctx"
[ -n "$cost" ] && line="$line  ·  $cost"
echo "$line"                                                 # footer
