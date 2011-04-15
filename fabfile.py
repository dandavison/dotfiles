import os
from fabric.api import local, run, env

env.hosts = ['analysis']

def deploy():
    sync_repos()
    validate_dotfiles()


def sync_repos():
    for d in ['config', 'bin', 'emacs']:
        local('cd ~/%s && git push' % d)
        run('cd ~/%s && git pull' % d)


def validate_dotfiles():
    targets = {}
    targets['~/.bashrc'] = '~/config/bash/bashrc'
    targets['~/.dircolors'] = '~/config/dircolors/dircolors'
    targets['~/.emacs'] = '~/config/emacs/emacs-init.el'
    targets['~/.emacs_bash'] = '~/config/emacs/emacs_bash'
    targets['~/.gitconfig'] = '~/config/git/gitconfig'
    targets['~/.gitignore'] = '~/config/git/gitignore'
    targets['~/.inputrc'] = '~/config/readline/inputrc'
    targets['~/.mailcap'] = '~/config/mailcap'
    targets['~/.mailrc'] = '~/config/email/mailrc'
    targets['~/.mairixrc'] = '~/config/mairix/mairixrc-gnus'
    targets['~/.mime-types'] = '~/config/mime.types'
    targets['~/.procmailrc'] = '~/config/procmailrc'
    targets['~/.Rprofile'] = '~/config/R/Rprofile.R'

    for link, target in targets.iteritems():
        link = os.path.expanduser(link)
        target = os.path.expanduser(target)

        if os.path.exists(link):
            run('rm ' + link)

        run('ln -s %s %s' % (target, link))
