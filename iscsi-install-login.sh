#! /bin/bash

log_file="/root/iscsi-install-login.log"


function log()
{
  echo -e "$(date +%b\ %d\ %H:%M:%S) $(hostname -s) iscsi-install-login: $@" >> $log_file
  echo -e "$(date +%b\ %d\ %H:%M:%S) $(hostname -s) iscsi-install-login: $@"
}


log "Attepnting to install open-iscsi"
if ! apt-get -y install open-iscsi &> /dev/null ; then
  log "FATAL: failed to install open-iscsi"
  exit 1
fi
  
log "Enableing node.startup as automatic"
if ! sed -i 's/GRUB_CMDLINE_LINUX=.*\+/GRUB_CMDLINE_LINUX="apparmor=0"/' /etc/default/grub; then
  log "FATAL: could not disable apparmor"
  exit 1
fi

