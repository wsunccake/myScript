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
[alias]
        co = checkout
        ci = commit
        st = status
        br = branch
EOF
}


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

