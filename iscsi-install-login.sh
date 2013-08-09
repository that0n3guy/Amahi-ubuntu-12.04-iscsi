#! /bin/bash

log_file="/root/iscsi-install-login.log"


function log()
{
  echo -e "$(date +%b\ %d\ %H:%M:%S) $(hostname -s) iscsi-install-login: $@" >> $log_file
  echo -e "$(date +%b\ %d\ %H:%M:%S) $(hostname -s) iscsi-install-login: $@"
}

#Ask for iscsi username
echo "Enter iscsi username: "
read username

#Ask for iscsi password
echo "Enter iscsi password: "
read password

log "Attempting to install open-iscsi"
if ! apt-get -y install open-iscsi &> /dev/null ; then
  log "FATAL: failed to install open-iscsi, try doing 'sudo apt-get install open-iscsi' manually."
  exit 1
fi
  
log "Setting node.startup = automatic"
if ! sed -i 's/# node.startup = automatic.*\+/node.startup = automatic/' /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set node.startup = automatic"
  exit 1
fi

log "Setting node.startup = manual"
if ! sed -i 's/node.startup = manual.*\+/# node.startup = manual/' /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set node.startup = manual"
  exit 1
fi

log "Setting node.session.auth.username"
if ! sed -i 's/#node.session.auth.username.*\+/node.session.auth.username = $username/' /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set node.session.auth.username"
  exit 1
fi

log "Setting node.session.auth.password"
if ! sed -i "s/#node.session.auth.password.*\+/node.session.auth.password = $password/" /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set node.session.auth.password"
  exit 1
fi