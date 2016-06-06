#!/bin/bash

# configure oopenvpn client
# https://lukas.dzunko.sk/index.php/MikrotTik:_OpenVPN
# http://wiki.mikrotik.com/wiki/OpenVPN#Unsupported
# http://freedommafia.net/clanmain/knowledges-management-42/mikrotik/317-mikrotik-router-openvpn-setup-os-6-0-or-newer

echo -n "Enter the address of your server (IP or domain) [ENTER]: "
read SERVER_ADDR

# you can find these with /certificate print (after uploading them)
CLIENT_CERT="client"
CONN_NAME="myvpn"
PPP_PROFILE="OVPN-client"

# create PPP profile
# http://wiki.mikrotik.com/wiki/Manual:PPP_AAA
ssh_eval "ppp profile remove $PPP_PROFILE" &>/dev/null
ssh_eval "ppp profile add \
change-tcp-mss=yes \
name=$PPP_PROFILE \
only-one=yes \
use-compression=default \
use-encryption=required \
use-mpls=no";

# http://wiki.mikrotik.com/wiki/Manual:Interface/OVPN
ssh_eval "interface ovpn-client remove $CONN_NAME" &>/dev/null
ssh_eval "interface ovpn-client add \
disabled=no \
add-default-route=no \
auth=sha1 \
certificate=$CLIENT_CERT \
connect-to=$SERVER_ADDR \
port=1194 \
user=vpnuser \
password=vpnpass \
name=$CONN_NAME \
profile=$PPP_PROFILE";

# http://wiki.mikrotik.com/wiki/Policy_Base_Routing
# http://wiki.mikrotik.com/wiki/Manual:IP/Firewall/Filter
echo "[info] adding firewall rules"
ssh_eval 'ip firewall address-list add address=10.0.0.0/8 disabled=no list=local_traffic'
ssh_eval 'ip firewall address-list add address=172.16.0.0/12 disabled=no list=local_traffic'
ssh_eval 'ip firewall address-list add address=192.168.0.0/16 disabled=no list=local_traffic'
ssh_eval 'ip firewall mangle add disabled=no action=mark-routing chain=prerouting dst-address-list=!local_traffic new-routing-mark=vpn_traffic passthrough=yes src-address=192.168.88.2-192.168.88.254'
ssh_eval 'ip route add disabled=no dst-address=0.0.0.0/0 type=unicast gateway=ukvpn routing-mark=vpn_traffic scope=30 target-scope=10'
ssh_eval 'ip firewall nat add chain=srcnat src-address=192.168.88.0/24 out-interface=ukvpn action=masquerade'

# monitor connection
ssh_eval 'interface ovpn-client monitor 0'
