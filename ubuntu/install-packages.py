#!/usr/bin/env python
import os

## packages to install
packages=' \
emacs-snapshot \
tree \
r-base r-base-dev \
ssh \
rar unrar \
mysql-server mysql-client \
texlive \
sysutils \
lame cdrecord \
manpages-dev \
imagemagick \
openmpi-bin openmpi-common openmpi-dbg openmpi-dev openmpi-libs0 \
lapack3 lapack3-dev lapack3-doc \
perl-doc \
git-core git-doc \
mairix \
ktorrent \
irb \
xkeycaps'


os.system('sudo aptitude install %s' % packages)

# ubuntu-restricted-extras \
# flashblock \
# deluge-torrent \
# pmount \
# gnome-vfs-obexftp \
# libdvdread3 libxine1-ffmpeg totem-xine \
# libdvdnav4 \
# amule \
# amarok \
# emacs22-gtk \
# compizconfig-settings-manager emerald gnome-compiz-manager \


## removed linux-headers-2.6.24-19-generic linux-headers-generic linux-image-2.6.24-19-generic linux-restricted-modules-2.6.24-19-generic linux-restricted-modules-generic
##  virtualbox-ose-modules-2.6.24-19-generic virtualbox-ose-modules-generic



