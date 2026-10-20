#!/usr/bin/env bash
# Sound + desktop popup when a Claude Code session finishes (Stop) or needs
# your input (Notification). Reads the hook's JSON payload on stdin.

input=$(cat)
event=$(jq -r '.hook_event_name // "Stop"' <<<"$input")
dir=$(jq -r '.cwd // empty' <<<"$input")
dir=${dir:-$PWD}

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
title="Claude Code: $(basename "$dir")${branch:+ ($branch)}"

if [ "$event" = "Notification" ]; then
  body=$(jq -r '.message // "Needs your attention"' <<<"$input")
  sound=bell
else
  body="Finished, waiting for your input"
  sound=complete
fi

paplay "/usr/share/sounds/freedesktop/stereo/$sound.oga" >/dev/null 2>&1 &
notify-send -a "Claude Code" -u normal -t 5000 "$title" "$body" 2>/dev/null
exit 0
