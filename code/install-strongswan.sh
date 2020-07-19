#!/bin/sh

set -e

# add user since we do not use the host's passwd and group file anymore
adduser "$SU_EXEC_USERSPEC"

# log output of initialization script to logs subfolder
logfile=/share/logs/install-stronswan-script-$(date +%s%N)

# install strongswan without user interaction
apt update >>$logfile 2>&1
apt install -y iproute2 --option=Dpkg::Options::=--force-confdef >>$logfile 2>&1
apt install -y strongswan --option=Dpkg::Options::=--force-confdef >>$logfile 2>&1
apt-get update -y >>$logfile 2>&1
apt-get install -y net-tools >>$logfile 2>&1
bash connect.sh >>$logfile 2>&1
bash startall.sh >>$logfile 2>&1
# execute scion service
/sbin/su-exec "$@"
