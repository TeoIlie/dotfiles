#!/usr/bin/env bash
# Build ~/Applications/ClaudeNotifier.app, a copy of terminal-notifier with a
# custom icon. macOS takes a notification's icon from the sending app, so the
# copy needs its own icon and bundle ID. Usage: make-notifier.sh IMAGE
# (.png, .jpg or .icns, ideally square).
set -euo pipefail

img=${1:?usage: make-notifier.sh IMAGE}
app=~/Applications/ClaudeNotifier.app
icns="$app/Contents/Resources/Terminal.icns"

rm -rf "$app"
cp -R ~/Applications/terminal-notifier.app "$app"

if [[ $img == *.icns ]]; then
  cp "$img" "$icns"
else
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  mkdir "$tmp/icon.iconset"
  for s in 16 32 128 256 512; do
    sips -z $s $s "$img" --out "$tmp/icon.iconset/icon_${s}x${s}.png" >/dev/null
    sips -z $((s * 2)) $((s * 2)) "$img" --out "$tmp/icon.iconset/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$tmp/icon.iconset" -o "$icns"
fi

plutil -replace CFBundleIdentifier -string com.teo.claude-notifier "$app/Contents/Info.plist"
plutil -replace CFBundleName -string "Claude Code" "$app/Contents/Info.plist"
codesign --force --deep -s - "$app"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
echo "Built $app; allow Claude Code in System Settings → Notifications"
