let-env PATH = (
  '/opt/twitter_mde/bin:/opt/twitter_mde/homebrew_minimal/mde_bin:/Users/ddavison/.nvm/versions/node/v14.9.0/bin:/Users/ddavison/.pyenv/shims:/Users/ddavison/bin:/Users/ddavison/.local/bin:/Users/ddavison/src/emacs-config/bin:/Users/ddavison/.cargo/bin:/opt/homebrew/opt/postgresql/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/sbin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/twitter_mde/data/node/bin:/Users/ddavison/.npm-global/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/Applications/Sublime Text.app/Contents/SharedSupport/bin:/opt/twitter_mde/data/gcloud/current/mde_bin'
  | split row ':'
)
let-env ALTERNATE_EDITOR = 'emacs -nw -q'
let-env BAT_THEME = 'GitHub'
let-env DELTA_PAGER = 'less -FRSX'
let-env EDITOR = 'emacsclient -n'
let-env FZF_DEFAULT_COMMAND = 'fd --type file --color=always'
let-env FZF_DEFAULT_OPTS = '--ansi'
let-env GIT_SEQUENCE_EDITOR = 'emacsclient'
let-env HOMEBREW_NO_AUTO_UPDATE = 1
let-env INFOPATH = '/opt/homebrew/share/info'
let-env LESS = '-FIRXS'
let-env LS_COLORS = (^vivid generate one-light | str trim)
let-env MANPATH = '/opt/homebrew/share/man'
let-env OPEN_IN_EDITOR = '~/bin/code'

