#!/bin/bash

set -e

brew_install () {
    brew list | grep -q "$1" || brew install "$1"
}


for pkg in $(cat <<EOF
coreutils
autoconf
automake
zsh
tmux
jpeg
wget
suite-sparse
swig
libyaml
gfortran
python
postgres
EOF
) ; do
    brew_install $pkg
done


for pkg in $(cat <<EOF
numpy
scipy
fabric
billiard
django-celery
pytz
pycrypto
zsi
beautifulsoup
pyyaml  
cython
pybedtools
pysam
pygr
pandas==0.7.3
pil
http://downloads.sourceforge.net/project/scikit-learn/scikits.learn-0.7.1.tar.gz
ipython
ipdb
boto
EOF
) ; do
    pip install $pkg
done


echo "Configure postgres db before installing psycopg2"

