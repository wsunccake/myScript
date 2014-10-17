#!/bin/sh
# Setup my tmux environment
# Modify Date: 2014/10/17
#

INSTALL () {
# Application Configuration
  TMUX_CONF $HOME/.tmux.conf
}

TMUX_CONF() {
inFile=$1
cat << EOF >>  $inFile
#
# Modified date: 2014/10/17
#

# Set function key
#set-option -g prefix C-a
#unbind-key C-b
#bind-key C-a send-prefix
set -g mode-keys vi 


# Statusbar properties
#set -g display-time 10
set -g status-utf8 on
#set -g status-bg white
#set -g status-fg green
#set -g status-right "#[fg=magenta]| %H:%M %d-%b-%Y %a"
#set -g status-left  "#[fg=red,bold]#H:#S"
setw -g window-status-format '#F#I #W'
setw -g window-status-current-format '#[fg=yellow,bold]#[bg=black]#F#I #W'

# Define bindkey
bind -n M-s split-window -v      # split horizontal pane
bind -n M-v split-window -h      # split vertical pane
bind -n M-k select-pane -U       # select up pane 
bind -n M-j select-pane -D       # select down pane
bind -n M-h select-pane -L       # select left pane
bind -n M-l select-pane -R       # select right pane
bind -n M-+ resize-pane -U 1     # resize up pane
bind -n M-- resize-pane -D 1     # resize down pane
bind -n M-< resize-pane -L 1     # resize left pane
bind -n M-> resize-pane -R 1     # resize right pane
#bind -n M-Up    resize-pane -U 1 # resize up pane
#bind -n M-Down  resize-pane -D 1 # resize down pane
#bind -n M-Left  resize-pane -L 1 # resize left pane
#bind -n M-Right resize-pane -R 1 # resize right pane


bind -n M-w choose-window        # select window
bind -n M-n new-window           # create window
bind -n M-a command-prompt "renamew '%%'" # setup screen title
bind -n M-L next                 # next window
bind -n M-H prev                 # prev window
#bind -n M- rotate-window -U      # rotate window  forward
#bind -n M- rotate-window -D      # rotate window downward

bind -n M-q choose-session       # select session
#bind -n M- switch-client -n     # next session
#bind -n M- switch-client -p     # prev session
#bind -n M- detach               # deatch session
#bind -n M- kill-session         # quit session

bind -n M-c copy-mode            # copy mode
bind -n M-p paste-buffer         # paste buffer
bind -n M-x choose-buffer        # select buffer
EOF
}



# Main Program
INSTALL
