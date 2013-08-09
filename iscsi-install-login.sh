#! /bin/bash

log_file="/root/iscsi-install-login.log"


function log()
{
  echo -e "$(date +%b\ %d\ %H:%M:%S) $(hostname -s) iscsi-install-login: $@" >> $log_file
  echo -e "$(date +%b\ %d\ %H:%M:%S) $(hostname -s) iscsi-install-login: $@"
}


if [[ -f /tmp/iscsi-install-login.run ]] ; then
    echo
    echo
    echo 'You have previously run this script,' 
    echo '  running it again will remove open-iscsi and its'
    echo '  config files before reinstalling (so it can start with a clean slate)'
    #ask if they want to continue
    read -p "Are you sure you want to continue? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        log "Attempting to remove open-iscsi"
        if ! apt-get --purge remove open-iscsi &> /dev/null ; then
          log "FATAL: failed to remove open-iscsi, try doing 'sudo apt-get --purge remove open-iscsi' manually."
          exit 1
        fi
        rm -f /tmp/iscsi-install-login.run
    else
        exit
    fi
fi

#Ask for iscsi username
echo "Enter iscsi username: "
read username

#Ask for iscsi password
echo "Enter iscsi password: "
read -s password

#Ask for iscsi password
echo "Re-enter iscsi password: "
read -s password2



if [ $password = $password2 ] ; then
  log "Oops: Passwords don't match... re-run script and try again"
  exit 1
fi


log "Attempting to install open-iscsi"
if ! apt-get -y install open-iscsi &> /dev/null ; then
  log "FATAL: failed to install open-iscsi, try doing 'sudo apt-get install open-iscsi' manually."
  exit 1
fi

touch /tmp/iscsi-install-login.run

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
if ! sed -i "s/#node.session.auth.username =.*\+/node.session.auth.username = $username/" /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set node.session.auth.username"
  exit 1
fi

log "Setting node.session.auth.password"
if ! sed -i "s/#node.session.auth.password =.*\+/node.session.auth.password = $password/" /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set node.session.auth.password"
  exit 1
fi

log "Setting discovery.sendtargets.auth.username"
if ! sed -i "s/#discovery.sendtargets.auth.username =.*\+/discovery.sendtargets.auth.username = $username/" /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set discovery.sendtargets.auth.username"
  exit 1
fi

log "Setting discovery.sendtargets.auth.password"
if ! sed -i "s/#discovery.sendtargets.auth.password =.*\+/discovery.sendtargets.auth.password = $password/" /etc/iscsi/iscsid.conf; then
  log "FATAL: could not set discovery.sendtargets.auth.password"
  exit 1
fi

