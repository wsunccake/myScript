#!/bin/sh
#
### modified date: 2014/10/17
#

INSTALL () {
# Application Configuration
  GITCONFIG $HOME/.gitconfig
}

GITCONFIG() {
inFile=$1
cat << EOF >>  $inFile
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

# alias for sh/bash
cat << EOF >> $HOME/.alias
alias git-tree="git log --graph --oneline --all"
alias git-showadd="git show --pretty=fuller"
EOF

# alias for csh/tcsh
cat << EOF >> $HOME/.aliases
alias git-tree "git log --graph --oneline --all"
alias git-showadd "git show --pretty=fuller"
EOF
}

# Main Program
INSTALL

