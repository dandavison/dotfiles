#!/usr/bin/env python

import os

targets = {}

targets['bin'] = 'bin'

targets['.bashrc'] = 'src/config/bash/bashrc'
targets['.dircolors'] = 'src/config/look/dircolors'
targets['.emacs'] = 'src/config/emacs/emacs-init.el'
targets['.emacs_bash'] = 'src/config/emacs/emacs_bash'
targets['.gconf'] = 'src/config/gnome/gconf'
targets['.gconfd'] = 'src/config/gnome/gconfd'
targets['.getmail'] = 'src/config/getmail'
targets['.gitconfig'] = 'src/config/git/gitconfig'
targets['.gitignore'] = 'src/config/git/gitignore'
targets['.gnus.el'] = 'src/config/emacs/gnus/gnus-dan.el'
targets['.inputrc'] = 'src/config/readline/inputrc'
# targets['.ion3'] = 'src/config/ion3'
targets['.mailcap'] = 'src/config/mailcap'
targets['.mailrc'] = 'src/config/email/mailrc'
targets['.mairixrc'] = 'src/config/mairix/mairixrc-gnus'
targets['.mime-types'] = 'src/config/email/mime.types'
# targets['.mutt'] = 'src/config/mutt'
targets['.procmailrc'] = 'src/config/procmailrc'
targets['.VirtualBox'] = '/usr/local/share/applications/virtual-box-windows-xp-pseudo-partition'
# targets['.Xclients'] = 'src/config/x11/xsession'
# targets['.xmodmap-Tichodroma'] = .xmodmap-Tichodroma-090511
# targets['.xsession'] = 'src/config/x11/xsession'

for link, target in targets.iteritems():
    if os.path.exists(link):
        print link
        os.rename(link, link + '-renamed-by-python-script')
    try:
        os.symlink(target, link)
    except Exception, e:
        print 'Failed: %s' % e

print('You will also need to do something like\n'
      'ln -s  .mozilla/firefox/hclx8zqh.default/bookmarkbackups')
