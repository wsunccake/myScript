#!/bin/sh

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

