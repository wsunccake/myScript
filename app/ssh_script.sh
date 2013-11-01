#!/bin/sh
# Setup my SSH environment
# Modify Date: 2013/10/18
#

INSTALL () {
# Application Configuration
  SSH_config  $HOME/.ssh/config
}

SSH_config () {
inFile=$1
SSH_DIR=$(dirname $inFile)
if [ ! -d $SSH_DIR ]; then
  mkdir -p $SSH_DIR
fi
cat << EOF >> $inFile
### example
#Host         localhost
#HostName     127.0.0.1
#User         user
#Port         22
#setup authentication identity
#IdentityFile ~/.ssh/id_rsa
#StrictHostKeyChecking no
#setup proxy
#ProxyCommand /usr/bin/nc -X 5 -x localhost:9000 %h %p #for BSD
#ProxyCommand /usr/bin/connect-proxy -H localhost:9000 %h %p" #for Linux

EOF
chmod 600 $inFile
}




# Main Program
INSTALL
