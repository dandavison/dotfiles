# macOS dotfiles

## `defaults/`

Snapshots of app settings held in the macOS user defaults system (NSUserDefaults) rather
than in a config file. These cannot be symlinked: cfprefsd caches preferences in memory
and rewrites the plist atomically, replacing any symlink. `manifest.json` lists the
domains to track and the keys to omit (history, analytics IDs, window geometry).

```bash
~/src/devenv/macos-defaults export   # capture current settings into this directory
~/src/devenv/macos-defaults import   # apply them on a new machine (quit the apps first)
```

`import` merges into the existing domain, so untracked keys are left alone.

### `org.alacritty.plist` — freeing Cmd-Q for tmux

winit hardcodes a native "Quit" menu item with key equivalent Cmd-Q, and AppKit
resolves menu key equivalents before Alacritty sees the key, so the Cmd-Q binding in
`dotfiles/alacritty/alacritty.toml` (tmux copy mode) could never fire. The fix is
`NSUserKeyEquivalents`, which reassigns Cmd-Q to `Show All`; a key equivalent belongs
to only one item, so Quit loses it. `Show All` is disabled whenever no application is
hidden, so it declines the event and it falls through to Alacritty's own bindings.

Caveat: while some application *is* hidden, Cmd-Q unhides it instead of entering copy
mode.

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
