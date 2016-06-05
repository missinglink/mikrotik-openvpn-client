#!/bin/bash

# configure network time server (most boards don't contain a clock battery)
# this is useful for systems requiring exact time for certificates to work
# http://wiki.mikrotik.com/wiki/Setup_local_NTP_servers

TIMEZONE="CET"

ssh_eval "system ntp server set broadcast=no enabled=yes manycast=yes multicast=no"
ssh_eval "system ntp client set enabled=yes primary-ntp=1.2.3.4 secondary-ntp=5.6.7.8"
ssh_eval "system clock set time-zone-name=$TIMEZONE"

echo "ntp server enabled"
echo "[warning] timezone set to $TIMEZONE, you may need to reconfigure this setting"
echo

ssh_eval "system clock print"
