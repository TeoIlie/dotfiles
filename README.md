# dotfiles

My tmux and starship configs, kept in sync across machines with git and symlinks.

| File in repo             | Linked to                   |
| ------------------------ | --------------------------- |
| `tmux/tmux.conf`         | `~/.tmux.conf`              |
| `starship/starship.toml` | `~/.config/starship.toml`   |

The real files live in this repo. `install.sh` creates symlinks so each program
finds its config where it expects it, which means editing either path edits the
same file.

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
2. Clone the repo and run the installer:

   ```bash
   git clone git@github.com:<you>/dotfiles.git ~/2.Personal/dotfiles
   ~/2.Personal/dotfiles/install.sh
   ```

Any existing config at a target path is moved to
`~/.dotfiles_backup/<timestamp>/` before it's replaced. The script is safe to
re-run: links that are already in place are left alone.

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

## Adding another config

1. Move the file into the repo, e.g. `mv ~/.config/foo/config ~/2.Personal/dotfiles/foo/config`.
2. Add a line to `LINKS` in `install.sh`: `"foo/config:$HOME/.config/foo/config"`.
3. Run `./install.sh`, update the table above, and commit.

Never commit secrets (tokens, SSH keys, `.env` files).
