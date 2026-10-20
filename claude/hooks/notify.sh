#!/usr/bin/env bash
# Bell + desktop popup when a Claude Code session needs input.
# Reads the hook's JSON payload on stdin (Stop / Notification events).
# Popups are critical so they get through GNOME Do Not Disturb. GNOME never
# expires critical popups itself, so we close them after POPUP_SECONDS.
POPUP_SECONDS=5

input=$(cat)
event=$(jq -r '.hook_event_name // "Stop"' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
session=$(jq -r '.session_id // "unknown"' <<<"$input")
msg=$(jq -r '.message // empty' <<<"$input")

project=$(basename "${cwd:-$PWD}")
branch=$(git -C "${cwd:-$PWD}" branch --show-current 2>/dev/null)
title="Claude Code: ${project}${branch:+ ($branch)}"

if [ "$event" = "Notification" ]; then
  body="${msg:-Needs your attention}"
  sound=/usr/share/sounds/freedesktop/stereo/bell.oga
  mac_sound=Ping
else
  body="Finished, waiting for your input"
  sound=/usr/share/sounds/freedesktop/stereo/complete.oga
  mac_sound=Glass
fi

# macOS: Notification Center plays the sound and dismisses banners itself.
# Text goes in as arguments so quotes in it can't break the AppleScript.
if [ "$(uname)" = Darwin ]; then
  osascript - "$title" "$body · session ${session:0:8}" "$mac_sound" >/dev/null 2>&1 <<'EOF'
on run argv
  display notification (item 2 of argv) with title (item 1 of argv) sound name (item 3 of argv)
end run
EOF
  exit 0
fi

body="$body\nsession ${session:0:8}"

paplay "$sound" 2>/dev/null &

# Remember this session's popup ID so a quick follow-up replaces it.
id_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-notify"
mkdir -p "$id_dir"
id_file="$id_dir/$session"
replace=()
[ -s "$id_file" ] && replace=(-r "$(cut -d" " -f1 "$id_file")")

id=$(notify-send -p "${replace[@]}" -a "Claude Code" -u critical -i dialog-information \
  "$title" "$body" 2>/dev/null) || exit 0
nonce="$id $(date +%s%N)"
echo "$nonce" >"$id_file"

# Close it later, unless a newer popup from this session has taken over the ID.
setsid bash -c '
  sleep "$1"
  [ "$(cat "$2" 2>/dev/null)" = "$3" ] || exit 0
  gdbus call --session --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.CloseNotification "$4" >/dev/null
  rm -f "$2"
' _ "$POPUP_SECONDS" "$id_file" "$nonce" "$id" </dev/null >/dev/null 2>&1 &
exit 0
