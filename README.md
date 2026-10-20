# dotfiles

My tmux, starship and Claude Code configs, kept in sync across machines with git
and symlinks.

| File in repo             | Linked to                      |
| ------------------------ | ------------------------------ |
| `tmux/tmux.conf`         | `~/.tmux.conf`                 |
| `starship/starship.toml` | `~/.config/starship.toml`      |
| `claude/mods/model-tail` | `~/.claude/mods/model-tail`    |
| `claude/hooks/notify.sh` | `~/.claude/hooks/notify.sh`    |

The real files live in this repo. `install.sh` creates symlinks so each program
finds its config where it expects it, which means editing either path edits the
same file.

## Supported systems

Everything here should work on these three:

- **Ubuntu** (GNOME, X11 or Wayland)
- **Omarchy** (Arch Linux with Hyprland, Wayland)
- **macOS**

The configs adapt to each one where needed: tmux picks the clipboard tool
(`xclip`, `wl-copy` or `pbcopy`) and falls back to `screen-256color` where the
`tmux-256color` terminal type is missing, and the Claude notification hook uses
Notification Center on macOS instead of `notify-send`. Keep changes working on
all three.

## Setup on a new machine

1. Install the dependencies:
   - [tmux](https://github.com/tmux/tmux) 3.2+ and [starship](https://starship.rs)
   - A [Nerd Font](https://www.nerdfonts.com) set as your terminal font (for the
     rounded segment caps and icons)
   - A clipboard tool so tmux copies reach the system clipboard: `xclip` on X11,
     `wl-clipboard` on Wayland (macOS has `pbcopy` built in). `tmux.conf` picks
     whichever is available. Without one, as over SSH, tmux falls back to OSC 52,
     which works if your terminal supports it.
   - Starship has to be enabled in your shell, e.g. `eval "$(starship init bash)"`
     in `~/.bashrc`
   - For the Claude notification hook: `jq` everywhere. On Linux also
     `notify-send` (libnotify), `paplay` (PulseAudio/PipeWire) and `gdbus`; on
     Arch, install `sound-theme-freedesktop` for the sounds. On macOS, allow
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
   the repo later, run `install.sh` again to repoint the links.
3. Add the Claude Code settings by hand, as described in [Claude Code](#claude-code).

An existing config file at a target path is moved to
`~/.dotfiles_backup/<timestamp>/` before it's replaced. An existing symlink is
simply replaced, since it holds no data; this also fixes stale links if you move
the repo. The script is safe to re-run: links that are already in place are left
alone.

## Daily usage

**Change a setting.** Edit the file either in the repo or at its usual path
(they're the same file), then reload:

```bash
tmux source-file ~/.tmux.conf   # or: prefix + :source-file ~/.tmux.conf
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
tmux source-file ~/.tmux.conf
```

Pulled edits take effect immediately because the files are symlinked. You only
need to re-run `install.sh` after adding a new config to the repo.

## Claude Code

The repo holds two Claude Code customizations:

- **`model-tail`**: a mod that shows the current model (e.g. "Opus 5.5") at the
  end of the prompt hint line. The code is in `hooks/register.ts`.
- **`notify.sh`**: a hook that plays a sound and shows a desktop popup when a
  session finishes or needs your permission.

`~/.claude/settings.json` is **not** synced. Claude Code rewrites it itself, and
it holds machine- and work-specific settings that don't belong in a public repo.
On a new machine, merge these keys into it once (create the file if it doesn't
exist), then restart Claude Code:

```json
{
  "env": {
    "CLAUDE_CODE_PLUGIN_DIRS": "~/.claude/mods/model-tail"
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

The mod's `.claude-plugin/types/` folder is generated editor type definitions and
is ignored by git; the mod runs without it.

## Adding another config

1. Move the file into the repo, e.g. `mv ~/.config/foo/config ~/2.Personal/dotfiles/foo/config`.
2. Add a line to `LINKS` in `install.sh`: `"foo/config:$HOME/.config/foo/config"`.
3. Run `./install.sh`, update the table above, and commit.

Never commit secrets (tokens, SSH keys, `.env` files).
