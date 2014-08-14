#!/bin/sh
#
### modified date: 2014/08/12
#

GITCONFIG() {
cat << EOF >> $HOME/.gitconfig
[color]
        ui = true
[core]
        editor = vim
[merge]
        tool = vimdiff
[alias]
	s = status -s -b -uno
	b = branch
	ba = branch -avv

	ci = commit -v -uno
        co = checkout

	l = log -C --stat --decorate
	t = log --graph --oneline --boundary --decorate --all --date-order
EOF
}

