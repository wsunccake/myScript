#!/bin/sh
# Setup my screen environment
# Modify Date: 2013/10/18
#

INSTALL () {
# Application Configuration
  SCREEN_RC $HOME/.screenrc
}

SCREEN_RC () {
inFile=$1
cat << EOF >  $inFile
#
# Modified date: 2011/11/18
#

# Display the  copyright  notice  during  startup
startup_message off

# Set scrollback line
defscrollback 1024

# Set default encoding using utf8
defutf8 on

# Set visual bell
vbell on

# Set split status always on
caption splitonly "%{= bK} %{= bG} [%n] %t @ %H"

# Set hardstatus always on
hardstatus alwayslastline "%{= WK} %-Lw%{= KY}%n%f %t%{-}%+Lw %{= WM} %=| %0c:%s  %Y-%m-%d"

# Set default screen
#screen -t bash 0 /bin/bash
#screen -t tcsh 1 /bin/tcsh
#chdir $HOME/project
#source $HOME/proecjt/project.sh
#screen -t ipython 2 /usr/bin/ipython


# Define bindkey
bindkey ^[s split      # split region
bindkey ^[o only       # detach all regrion but keep current region
bindkey ^[t focus      # switch input focus region

bindkey ^[[ copy       # copy region to buffer
bindkey ^[] paste .    # paste region from buffter

bindkey ^[r remove     # remove region
bindkey ^[k focus up   # previous region
bindkey ^[j focus down # next region
bindkey ^[\\" windowlist # select window list
bindkey ^[= resize +1  # increase region size
bindkey ^[- resize -1  # decrease region size

bindkey ^[c screen     # create screen
bindkey ^[a title      # setup screen title
bindkey ^[l next       # next screen
bindkey ^[h prev       # previous screen

bindkey ^[* displays   # list all attach session
bindkey ^[d detach     # detach session
bindkey ^[q quit       # quit session
EOF
}



# Main Program
INSTALL
