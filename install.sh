#!/bin/bash

ADDR="192.168.88.1"
SSH_USER="admin"

source util.sh
source task/header.sh

# ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R 192.168.88.1 &>/dev/null
healthcheck

# print installed packages
source "task/pkg.list.sh"; hr
# task "Update system packages" "task/pkg.update.sh"
# task "Install extra packages" "task/pkg.install.sh"
# task "Configure NTP client/server" "task/pkg.ntp.configure.sh"

task "Install certificates" "task/cert.install.sh"
task "Configure openvpn client" "task/ovpn.setup.sh"
