# dotfiles

My tmux, starship and Claude Code configs, kept in sync across machines with git
and symlinks.

The real files live in this repo. `install.sh` symlinks each one to where its
program expects it (the `LINKS` list at the top of the script shows what goes
where), so editing either path edits the same file.

## Supported systems

- **Ubuntu** 24.04+ (GNOME, X11 or Wayland)
- **Omarchy** (Arch Linux with Hyprland, Wayland)
- **macOS** 15+ (zsh, Ghostty)

The same files are used everywhere. The only per-platform branches are the
dependency checks at the end of `install.sh` and how `notify.sh` shows its
popup (a custom-icon copy of terminal-notifier on macOS, falling back to
`osascript`; `notify-send` on Linux).

`tmux.conf` is Omarchy's default tmux config. It lives at
`~/.config/tmux/tmux.conf`, where Omarchy puts it, so `prefix q` (reload) works
on every machine. The comment at the top of the file lists what differs from
Omarchy's version: mainly the `C-a` prefix (Omarchy ships `C-Space`), and
`prefix ?` showing tmux's own key list when Omarchy isn't installed.

## Omarchy notes

Omarchy owns `~/.config/tmux/tmux.conf` and `~/.config/starship.toml` and
changes them in a few ways that matter here:

- **Updates can break the links.** `omarchy-update` sometimes edits these
  files. Most edits write through the symlink into this repo. Some (those using
  `sed -i`) replace the symlink with a plain file instead, and the repo
  silently stops tracking it. So after every `omarchy-update`, run:

  ```bash
  ~/2.Personal/dotfiles/install.sh          # relinks anything an update replaced
  git -C ~/2.Personal/dotfiles status       # shows edits written into the repo
  ```

  If `install.sh` prints a `backup` line, an update replaced that link. Diff
  the backed-up file against the repo to see what the update changed, and copy
  over anything you want to keep. Use `git checkout -- <file>` to undo repo
  edits you don't want.
- **`omarchy-refresh-tmux` overwrites the repo copy.** It copies Omarchy's
  default over `tmux.conf` through the link, which brings back the `C-Space`
  prefix. Use `git checkout -- tmux/tmux.conf` to undo it.
- **Themes still apply.** The tmux colours are named terminal colours (`blue`,
  `brightblack`), so they follow whichever Omarchy theme is active.
- **Starship is already enabled.** Omarchy's `~/.bashrc` sources Omarchy's
  `default/bash/rc`, which runs `starship init`, so you don't need to add it.
  `install.sh` recognises this.

## macOS notes

- **Option as Alt.** The `M-…` tmux bindings (`M-Enter`, `M-1`…`M-9`,
  `M-arrows`) need the Option key to send Alt. In Ghostty, add
  `macos-option-as-alt = true` to its config (Cmd+, opens it).
- **Old `~/.tmux.conf`.** tmux loads `~/.tmux.conf` as well as
  `~/.config/tmux/tmux.conf`, so leftover settings from it (e.g. a different
  `copy-command` or unbound keys) mix with this config. Move any existing one
  aside before linking; `install.sh` warns if it's there.
- **Notification permission.** `notify.sh` posts through
  `~/Applications/ClaudeNotifier.app` (see
  [Custom notification icon](#custom-notification-icon-macos)). Run from a
  terminal, it never gets a permission prompt: macOS marks it denied and it
  exits 3. Turn on **Claude Code** in System Settings → Notifications by hand,
  and again after each rebuild. Without the app, `notify.sh` falls back to
  `osascript`, which posts as Script Editor; grant that by running
  `display notification "test"` in Script Editor and clicking **Allow**.
- **Focus must be off.** Do Not Disturb or any Focus mode (e.g. Work) silently
  hides the popups and their sounds; `notify.sh` still exits 0, so nothing
  looks broken. Turn Focus off, or add Claude Code (or Script Editor, for the
  fallback) to that Focus's allowed apps.
- **Clipboard.** tmux copies go through OSC 52, which works in Ghostty but not
  in the VS Code terminal.

## Setup on a new machine

1. Install the dependencies:

   ```bash
   # Ubuntu (starship isn't in 24.04's apt)
   sudo apt install tmux jq libnotify-bin pulseaudio-utils sound-theme-freedesktop
   curl -sS https://starship.rs/install.sh | sh

   # Omarchy (most of these are preinstalled)
   sudo pacman -S --needed tmux starship jq libnotify sound-theme-freedesktop

   # macOS (jq ships with macOS 15)
   brew install tmux
   curl -sS https://starship.rs/install.sh | sh
   ```

   Starship comes from its own installer rather than Homebrew because on Intel
   Macs Homebrew may have no prebuilt package and builds from source:
   `brew install starship` then compiles the whole Rust toolchain first (hours).
   tmux builds from source in a few minutes if needed.

   You also need:
   - tmux 3.3+ (for `display-popup -T` and `allow-passthrough`)
   - A [Nerd Font](https://www.nerdfonts.com) set as your terminal font (for the
     icons in the prompt's git status)
   - A terminal that supports OSC 52 (e.g. Alacritty, Kitty, Ghostty): tmux
     copies reach the system clipboard through the terminal (`set-clipboard on`),
     with no separate clipboard tool
   - Starship enabled in your shell: `eval "$(starship init bash)"` in `~/.bashrc`
     on Ubuntu (Omarchy already does this), or `eval "$(starship init zsh)"` in
     `~/.zshrc` on macOS
2. Clone the repo and run the installer:

   ```bash
   git clone https://github.com/TeoIlie/dotfiles.git ~/2.Personal/dotfiles
   ~/2.Personal/dotfiles/install.sh
   ```

   The repo can live anywhere; `~/2.Personal/dotfiles` is just where it is on
   my machines, and the paths in this README assume it. `install.sh` finds the
   repo from its own location and links to it by absolute path, so if you move
   the repo later, run `install.sh` again to repoint the links. Existing config
   files are moved to `~/.dotfiles_backup/<timestamp>/` first, and re-running
   the script is safe. At the end it lists any missing dependencies or
   leftover files (like an old `~/.tmux.conf`); it doesn't install anything.
3. Add the Claude Code settings by hand, as described in [Claude Code](#claude-code).

## Daily usage

**Change a setting.** Edit the file either in the repo or at its usual path
(they're the same file), then reload:

```bash
tmux source-file ~/.config/tmux/tmux.conf   # or: prefix + q
```

Starship picks up changes on the next prompt.

**Save and share the change:**

```bash
cd ~/2.Personal/dotfiles
git add -A
git commit -m "tmux: describe the change"
git push
```

**Get changes on another machine:**

```bash
cd ~/2.Personal/dotfiles
git pull
tmux source-file ~/.config/tmux/tmux.conf
```

Pulled edits take effect immediately because the files are symlinked. You only
need to re-run `install.sh` after adding a new config to the repo.

## Claude Code

Two Claude Code customizations:

- **`notify.sh`** (in the repo): a hook that plays a sound and shows a desktop
  popup when a session finishes or needs your permission. On Linux, popups use
  normal urgency, so they expire on their own and respect Do Not Disturb. On
  macOS they're regular Notification Center banners with the Glass (finished)
  or Ping (needs permission) sound, and a custom icon (see below).
- **Model name** (settings only): a `statusLine` that shows the current model,
  dimmed, as `◆ Opus 5.5` on its own line under the prompt.

If you used the old `model-tail` mod, delete `~/.claude/mods/model-tail` and the
`CLAUDE_CODE_PLUGIN_DIRS` entry in `env`.

`~/.claude/settings.json` is **not** synced. Claude Code rewrites it itself, and
it holds machine- and work-specific settings that don't belong in a public repo.
On a new machine, merge these keys into it once (create the file if it doesn't
exist), then restart Claude Code:

```json
{
  "statusLine": {
    "type": "command",
    "command": "jq -r '\"\\u001b[2m◆ \" + (.model.display_name // \"unknown\") + \"\\u001b[0m\"'"
  },
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh", "timeout": 10 }] }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt|elicitation_dialog",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh", "timeout": 10 }]
      }
    ]
  },
  "model": "opus",
  "editorMode": "vim",
  "tui": "fullscreen",
  "theme": "auto"
}
```

### Custom notification icon (macOS)

macOS takes a notification's icon from the sending app, and terminal-notifier
3.x dropped `-sender` and `-appIcon`. So `notify.sh` uses a copy of
[terminal-notifier](https://github.com/julienXX/terminal-notifier) with its own
icon and bundle ID:

1. Download `terminal-notifier-3.1.0.zip` from the project's GitHub releases
   and move `terminal-notifier.app` to `~/Applications`. (On Intel Macs
   `brew install terminal-notifier` builds from source and needs full Xcode.)
2. Build the copy from any square image, and re-run this to change the icon:

   ```bash
   ~/2.Personal/dotfiles/claude/hooks/make-notifier.sh /Applications/Ghostty.app/Contents/Resources/Ghostty.icns
   ```

3. Allow **Claude Code** in System Settings → Notifications, then test:

   ```bash
   ~/Applications/ClaudeNotifier.app/Contents/MacOS/terminal-notifier -message test; echo "exit $?"
   ```

   Exit 3 means permission is still off (`-diagnose` says why). If a banner
   shows the old icon, `killall NotificationCenter` clears the cache.

## Adding another config

1. Move the file into the repo, e.g. `mv ~/.config/foo/config ~/2.Personal/dotfiles/foo/config`.
2. Add a line to `LINKS` in `install.sh`: `"foo/config:$HOME/.config/foo/config"`.
3. Run `./install.sh` and commit.

Never commit secrets (tokens, SSH keys, `.env` files).
