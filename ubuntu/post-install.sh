## config file symlinks
mv ~/.bashrc ~/.bashrc.renamed
ln -s ~/src/config/bash/bashrc ~/.bashrc
ln -s ~/src/config/readline/inputrc_dan ~/.inputrc
ln -s ~/src/config/look/dircolors ~/.dircolors
ln -s ~/src/bin/ ~/bin
ln -s ~/src/config/emacs/emacs.el ~/.emacs
mv ~/.ion3 ~/.ion3.renamed
ln -s ~/src/config/ion3 ~/.ion3

## header file symlinks
for header in \
    common/dan.h common/io.h common/iogeno.h \
    blas-lapack/blas-lapack-dan.h ; do
    
    ln -s -t src/include ../$header ## must be relative to work on other machines
done


## application .* config files
for app in ssh mozilla ; do
    mv ~/.$app ~/.$app.renamed
    cp -r /mnt/xd/dan/backup/2008-01-29/dan/.$app ~/
done

## gconf
mkdir ~/src/config/gnome
mv ~/.gconf ~/src/config/gnome && ln -s $_ ~/.gconf
mv ~/.gconfd ~/src/config/gnome && ln -s $_ ~/.gconfd


chmod o-r ~/.ssh/*
chmod a-x ~/.ssh/*



## set apt sources
echo deb http://www.stats.bris.ac.uk/R/bin/linux/ubuntu gutsy/ | \
    sudo cat - /etc/apt/sources.list > /var/tmp/tmp && \
    sudo mv /var/tmp/tmp /etc/apt/sources.list


sudo apt-get update

sudo /usr/share/doc/libdvdread3/install-css.sh

## I have manually installed the following (executables in /usr/local/bin)
##
## id3lib http://id3lib.sourceforge.net/

cd /usr/src
sudo wget http://ess.r-project.org/downloads/ess/ess-5.3.6.tgz
sudo tar -xzvf ess-5.3.6.tgz
cd ~



## R packages
R-packages=Blighty RColorBrewer

## windows virtual machine
## http://lifehacker.com/367714/run-windows-apps-seamlessly-inside-linux
