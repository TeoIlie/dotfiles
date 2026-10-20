# dotfiles

My tmux, starship and Claude Code configs, kept in sync across machines with git
and symlinks.

The real files live in this repo. `install.sh` symlinks each one to where its
program expects it (the `LINKS` list at the top of the script shows what goes
where), so editing either path edits the same file.

## Supported systems

Everything here should work on these three:

- **Ubuntu** (GNOME, X11 or Wayland)
- **Omarchy** (Arch Linux with Hyprland, Wayland)
- **macOS**

Platform differences are handled inside the configs themselves (a `uname` check
in `notify.sh`), so keep changes working on all three.

`tmux.conf` is Omarchy's default tmux config, copied as is so it stays identical
everywhere. It lives at `~/.config/tmux/tmux.conf`, where Omarchy puts it, so
`prefix q` (reload) works on every machine. `prefix ?` opens Omarchy's
keybinding menu and does nothing elsewhere. If you set up a machine with an
older version of this repo, delete the `~/.tmux.conf` link, since tmux loads
both files.

## Setup on a new machine

1. Install the dependencies:
   - [tmux](https://github.com/tmux/tmux) 3.2+ and [starship](https://starship.rs)
   - A [Nerd Font](https://www.nerdfonts.com) set as your terminal font (for the
     icons in the prompt's git status)
   - A terminal that supports OSC 52 (e.g. Alacritty, Kitty, Ghostty, iTerm2):
     tmux copies reach the system clipboard through the terminal
     (`set-clipboard on`), with no separate clipboard tool.
   - Starship has to be enabled in your shell, e.g. `eval "$(starship init bash)"`
     in `~/.bashrc`
   - For the Claude notification hook: `jq` everywhere. On Linux also
     `notify-send` (libnotify) and `paplay` (PulseAudio/PipeWire); on Arch,
     install `sound-theme-freedesktop` for the sounds. On macOS, allow
     notifications for **Script Editor** in System Settings → Notifications,
     since popups are sent through AppleScript
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
   the script is safe.
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

The model name used to come from a mod (`model-tail`) that wrote it onto the end
of the prompt hint line. That relied on Claude Code's internal UI hooks, whose
props differ between versions: on 2.1.280 the mod loaded but was silently
ignored. `statusLine` is a documented setting that Claude Code feeds session
JSON (including `.model.display_name`), so it works the same everywhere. The
cost is one extra line on screen. If you installed the mod earlier, delete
`~/.claude/mods/model-tail` and the `CLAUDE_CODE_PLUGIN_DIRS` entry in `env`.

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
