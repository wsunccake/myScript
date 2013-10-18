#!/bin/sh
#
### modified date: 2013/10/18
#

GITCONFIG() {
cat << EOF > $HOME/.gitconfig
[color]
        ui = true
[core]
        editor = vim
[merge]
        tool = vimdiff
EOF
}

