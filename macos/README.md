# macOS dotfiles

## Files

### `DefaultKeyBinding.dict`

Disables Ctrl-/ (which macOS interprets as an input method shortcut).

**Deploy:**

```bash
mkdir -p ~/Library/KeyBindings
ln -s ~/src/devenv/dotfiles/macos/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
```

Requires logout/login to take effect.

### `my.startup.plist`

LaunchAgent that sets `OPEN_IN_EDITOR` env var at login.

**Deploy:**

```bash
ln -s ~/src/devenv/dotfiles/macos/my.startup.plist ~/Library/LaunchAgents/my.startup.plist
launchctl load ~/Library/LaunchAgents/my.startup.plist
```

### `my.docker-guard.plist`, `docker-guard`, `docker-start`, `docker-stop`

LaunchAgent + scripts to prevent Docker Desktop from running unless explicitly wanted.
Kandji's Auto App management starts Docker Desktop after updates; this guard quits it
within 30s unless `~/.docker-wanted` exists.

- `docker-start` — touches flag, opens Docker Desktop
- `docker-stop` — quits Docker Desktop, removes flag
- `docker-guard` — runs every 30s via launchd, quits Docker if flag absent

**Deploy:**

```bash
ln -s ~/src/devenv/dotfiles/macos/my.docker-guard.plist ~/Library/LaunchAgents/my.docker-guard.plist
for f in docker-guard docker-start docker-stop; do
  ln -s ~/src/devenv/dotfiles/macos/$f ~/.local/bin/$f
done
launchctl load ~/Library/LaunchAgents/my.docker-guard.plist
```

### `my.clean-login.plist`

LaunchAgent that clears the macOS "reopen apps at login" list on every login.
Prevents macOS from restoring previously-open applications after a restart,
regardless of the "Reopen windows when logging back in" checkbox state.

**Deploy:**

```bash
ln -s ~/src/devenv/dotfiles/macos/my.clean-login.plist ~/Library/LaunchAgents/my.clean-login.plist
launchctl load ~/Library/LaunchAgents/my.clean-login.plist
```
