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

### `my.clean-login.plist`

LaunchAgent that clears the macOS "reopen apps at login" list on every login.
Prevents macOS from restoring previously-open applications after a restart,
regardless of the "Reopen windows when logging back in" checkbox state.

**Deploy:**

```bash
ln -s ~/src/devenv/dotfiles/macos/my.clean-login.plist ~/Library/LaunchAgents/my.clean-login.plist
launchctl load ~/Library/LaunchAgents/my.clean-login.plist
```
