#!/usr/bin/env python

import os

targets = {}

targets['.bashrc'] = '~/config/bash/bashrc'
targets['.dircolors'] = '~/config/dircolors/dircolors'
targets['.emacs'] = '~/config/emacs/emacs-init.el'
targets['.emacs_bash'] = '~/config/emacs/emacs_bash'
targets['.gitconfig'] = '~/config/git/gitconfig'
targets['.gitignore'] = '~/config/git/gitignore'
targets['.inputrc'] = '~/config/readline/inputrc'
targets['.mailcap'] = '~/config/mailcap'
targets['.mailrc'] = '~/config/email/mailrc'
targets['.mairixrc'] = '~/config/mairix/mairixrc-gnus'
targets['.mime-types'] = '~/config/mime.types'
targets['.procmailrc'] = '~/config/procmailrc'

for link, target in targets.iteritems():
    if os.path.exists(link):
        newname = link + '-renamed'
        print '%s moved to %s' % (link, newname) 
        os.rename(link, newname)
    try:
        os.symlink(target, link)
    except Exception, e:
        print 'Failed: %s' % e
