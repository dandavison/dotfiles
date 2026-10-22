#!/bin/bash
# Claude Code status line: show the conversation name in the footer and the
# terminal tab/pane title. Prefers an explicit session name (--name / /rename),
# falling back to the auto-generated ai-title from the transcript, truncated.
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
# /rename records a custom-title in the transcript but does not set session_name.
if [ -z "$name" ] && [ -n "$transcript" ]; then
  name=$(jq -r 'select(.type=="custom-title") | .customTitle' "$transcript" 2>/dev/null | tail -1)
fi
if [ -z "$name" ] && [ -n "$transcript" ]; then
  name=$(jq -r 'select(.type=="ai-title") | .aiTitle' "$transcript" 2>/dev/null | tail -1)
  [ ${#name} -gt 24 ] && name="${name:0:23}…"
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
      | $lt | strftime("%b %d %H:%M")
    end' "$transcript" 2>/dev/null)

# The number of turns I typed, the turn of the last write-back to a GitHub issue,
# and, if the session was started from an `agent ctx` context (its first message),
# that context's recipe and sources by kind.
[ -n "$transcript" ] && stats=$(jq -rn '
  def typed: .type=="user" and (.message.content|type)=="string"
    and (.message.content|test("^\\s*<(local-command|task-notification|system-reminder|bash-)")|not);
  def kind: if startswith("issue:") or test("^https://github.com/") then "issue"
    elif startswith("slack:") or test("^https://[^/]+\\.slack\\.com/") then "slack"
    else split(":")[0] end;
  reduce inputs as $r ({turn: 0, wb: null, ctx: null};
    if ($r|typed) then
      .turn += 1
      | if .turn == 1 and ($r.message.content|test("^\\s*(<pasted_content[^>]*>\\s*)?# Context\n"))
        then .ctx = $r.message.content else . end
    elif $r.type=="assistant" and any($r.message.content[]?;
        .type=="tool_use" and ((.input.command // "")|test("gh issue (comment|edit|create)")))
    then .wb = .turn
    else . end)
  | "turn \(.turn) [written back \(.wb // "never")]",
    (.ctx // "" | [splits("\n")] as $lines
     | ($lines | map(capture("^Recipe: \\S*/(?<n>[^/]+)\\.toml ")) | first | .n // "") as $recipe
     | ($lines | map(capture("^\\| (?<uri>.*) \\| raw \\| (?<t>[0-9]+) \\|$"))) as $rows
     | if ($rows|length) == 0 then "" else
         ($rows | group_by(.uri|kind) | map("\(.[0].uri|kind)×\(length)") | join(" ")) as $kinds
         | "\($recipe)\(if $recipe == "" then "" else " " end)[\($kinds), \(($rows | map(.t|tonumber) | add) / 1000 | floor)k]"
       end)' "$transcript" 2>/dev/null)
turns=$(sed -n 1p <<<"$stats")
sources=$(sed -n 2p <<<"$stats")

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
[ -n "$effort" ] && model="$model ($effort)"
case "$(echo "$input" | jq -r '.model.id // empty')" in
  *opus*) model_color=$dim ;;
  *) model_color=$red ;;
esac

# Who is billed: an API key overrides the logged-in account.
if [ -n "$ANTHROPIC_API_KEY" ]; then
  payer="${yellow}api-key$reset"
else
  email=$(jq -r '.oauthAccount.emailAddress // empty' "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" 2>/dev/null)
  case "$email" in
    *@temporal.io) payer="${dim}temporal$reset" ;;
    "") payer="" ;;
    *) payer="$bold${yellow}personal$reset" ;;
  esac
fi

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
session_code=${session_id:0:8}

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
[ -n "$turns" ] && line="$line │ $dim$turns$reset"
[ -n "$sources" ] && line="$line │ $cyan$sources$reset"

[ -n "$model" ] && line="$line │ $model_color$model$reset"
billing="${cost:+$dim$cost$reset}${cost:+${payer:+ }}$payer"
[ -n "$billing" ] && line="$line │ $billing"
[ -n "$ctx" ] && line="$line │ $ctx"
[ -n "$age" ] && line="$line │ $dim$age$reset"

echo "$line"
