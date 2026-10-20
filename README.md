# dotfiles

My tmux, starship and Claude Code configs, kept in sync across machines with git
and symlinks.

The real files live in this repo. `install.sh` symlinks each one to where its
program expects it (the `LINKS` list at the top of the script shows what goes
where), so editing either path edits the same file.

## Supported systems

Linux only:

- **Ubuntu** 24.04+ (GNOME, X11 or Wayland)
- **Omarchy** (Arch Linux with Hyprland, Wayland)

The same files are used on both, with no per-platform branches.

`tmux.conf` is Omarchy's default tmux config. It lives at
`~/.config/tmux/tmux.conf`, where Omarchy puts it, so `prefix q` (reload) works
on every machine. The only change from Omarchy's version: `prefix ?` opens
Omarchy's keybinding menu when it's installed and tmux's own key list
otherwise.

**Omarchy updates.** Omarchy owns `~/.config/tmux/tmux.conf` and
`~/.config/starship.toml`. If an update rewrites them, it writes through the
symlink into this repo. After updating, run `git -C ~/2.Personal/dotfiles status`
and `git checkout -- <file>` to undo any change you don't want.

## Setup on a new machine

1. Install the dependencies:

   ```bash
   # Ubuntu (starship isn't in 24.04's apt)
   sudo apt install tmux jq libnotify-bin pulseaudio-utils sound-theme-freedesktop
   curl -sS https://starship.rs/install.sh | sh

   # Omarchy (most of these are preinstalled)
   sudo pacman -S --needed tmux starship jq libnotify sound-theme-freedesktop
   ```

   You also need:
   - tmux 3.3+ (for `display-popup -T` and `allow-passthrough`)
   - A [Nerd Font](https://www.nerdfonts.com) set as your terminal font (for the
     icons in the prompt's git status)
   - A terminal that supports OSC 52 (e.g. Alacritty, Kitty, Ghostty): tmux
     copies reach the system clipboard through the terminal (`set-clipboard on`),
     with no separate clipboard tool
   - Starship enabled in your shell: `eval "$(starship init bash)"` in `~/.bashrc`
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
  popup when a session finishes or needs your permission. Popups use normal
  urgency, so they expire on their own and respect Do Not Disturb.
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

## Adding another config

1. Move the file into the repo, e.g. `mv ~/.config/foo/config ~/2.Personal/dotfiles/foo/config`.
2. Add a line to `LINKS` in `install.sh`: `"foo/config:$HOME/.config/foo/config"`.
3. Run `./install.sh` and commit.

Never commit secrets (tokens, SSH keys, `.env` files).
