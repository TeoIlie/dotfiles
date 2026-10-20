#!/usr/bin/env bash
# Symlink the configs in this repo into place. Safe to re-run: links that
# already point here are skipped, and existing files are backed up first.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

# "source in repo:target on this machine"
LINKS=(
  "tmux/tmux.conf:$HOME/.tmux.conf"
  "starship/starship.toml:$HOME/.config/starship.toml"
  "claude/hooks/notify.sh:$HOME/.claude/hooks/notify.sh"
)

for entry in "${LINKS[@]}"; do
  src="$DOTFILES/${entry%%:*}"
  dst="${entry#*:}"

  if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
    echo "ok       $dst"
    continue
  fi

  # A symlink holds no data (e.g. a stale one left after moving this repo),
  # so replace it directly; only real files get backed up.
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    echo "backup   $dst -> $BACKUP/"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked   $dst -> $src"
done

# Reload tmux if a server is running
if command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
  tmux source-file "$HOME/.tmux.conf" && echo "reloaded tmux"
fi
