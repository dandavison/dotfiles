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

{ printf '\033]0;%s\007' "$name" > /dev/tty; } 2>/dev/null   # tab/pane title
echo "$name"                                          # footer
