import os
from fabric.api import local, run, env

env.hosts = ['analysis']

REPOS = [('~/bin', 'git@github.com:dandavison/bin.git'),
         ('~/bin/counsyl', 'analysis:bin-counsyl'),
         ('~/config', 'analysis:config'),
         ('~/config/bash/bashrc', 'git@github.com:dandavison/bashrc.git'),
         ('~/config/emacs', 'git@github.com:dandavison/emacs-config.git')]


def deploy(counsyl=False):
    set_links()
    sync_repos()


def sync_repos():
    for dir, url in REPOS:
        local('cd %s && git push' % dir)
        if run('test -d %s' % dir).failed:
            run('git clone %s %s' % (url, dir))
        run('cd %s && git pull' % dir)


def set_links():
    targets = {}
    targets['~/.bashrc'] = '~/config/bash/bashrc'
    targets['~/.dircolors'] = '~/config/dircolors/dircolors'
    targets['~/.emacs'] = '~/config/emacs/emacs-init.el'
    targets['~/.gitconfig'] = '~/config/git/gitconfig'
    targets['~/.gitignore'] = '~/config/git/gitignore'
    targets['~/.inputrc'] = '~/config/bash/bindings'
    targets['~/.mailcap'] = '~/config/mailcap'
    targets['~/.mairixrc'] = '~/config/mairix/mairixrc-gnus'
    targets['~/.Rprofile'] = '~/config/R/Rprofile.R'

    for link, target in targets.iteritems():

        if run('test -f %s' % link).succeeded:
            run('rm %s' % link)

        run('ln -s %s %s' % (target, link))
