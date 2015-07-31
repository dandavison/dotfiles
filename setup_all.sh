cd /tmp
for repo in config shell-config emacs-config; do
    git clone "https://github.com/dandavison/$repo.git"
    sh $repo/setup.sh
done
