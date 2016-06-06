# Mikrotik router as OpenVPN Client

There are a bunch of tutorials online about how to set up a Mikrotik routerboard as an OpenVPN *server*; this is not one of them, this repository contains information and code samples for configuring a Mikrotik router as a *client* to connect to your own OpenVPN server hosted elsewhere.

As of Jun '16 this is confirmed working on a Mikrotik 951Ui-2HnD routerboard, all traffic destined for the internet is routed via the VPN connection and I'm able to watch region-locked video streaming services while connected through this wifi network.

## Gotchas!

Sourced from: http://wiki.mikrotik.com/wiki/OpenVPN

- TCP is supported **UDP is not supported** (ie. the default setup is not supported)
- username/passwords **are not mandatory**
- certificates are supported
- LZO compression **is not supported**

## Setting up the server

This info applies to you if you are setting up the server for yourself, otherwise you best check with your server admin that they have configured the server for a Mikrotik client.

For the most part I followed [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-14-04) for installing OpenVPN server on Ubuntu 14.04.

> Be careful with this tutorial, if you are using any services other than OpenVPN and SSH; or if you use non-standard ports, make sure you add the corresponding firewall rules!

I only made a couple changes to my `server.conf`:

##### Change protocols from UDP to TCP

```
# TCP or UDP server?
proto tcp
;proto udp
```

add the corresponding firewall rule:

```bash
sudo ufw allow 1194/tcp
```

##### Disable compression (optional)

This step is optional, if you're streaming video you can disable compression by commenting it out:

```
# comp-lzo
```

## Setting up the client

This section covers the steps required to set up your Mikrotik routerboard as an OpenVPN client.

##### Copy files from server

You'll need some files from your OpenVPN server or VPN provider, only 3 files are required:

```
$ ls cert/
ca.crt  client.crt  client.key
```

> If you're using the scripts in this repo then you'll need to create a directory called `cert` and put those files inside. You'll also need to rename your client keys to match the file names above.

##### Establish a SSH session

All the commands are executed by SSH so you'll need SSH access to your routerboard before continuing, otherwise I guess you could read the commands and enter them in the GUI, up to you.

```bash
ssh admin@192.168.88.1
```

```bash

MMM      MMM       KKK                          TTTTTTTTTTT      KKK
MMMM    MMMM       KKK                          TTTTTTTTTTT      KKK
MMM MMMM MMM  III  KKK  KKK  RRRRRR     OOOOOO      TTT     III  KKK  KKK
MMM  MM  MMM  III  KKKKK     RRR  RRR  OOO  OOO     TTT     III  KKKKK
MMM      MMM  III  KKK KKK   RRRRRR    OOO  OOO     TTT     III  KKK KKK
MMM      MMM  III  KKK  KKK  RRR  RRR   OOOOOO      TTT     III  KKK  KKK

MikroTik RouterOS 6.35.2 (c) 1999-2016       http://www.mikrotik.com/

[?]             Gives the list of available commands
command [?]     Gives help on the command and list of arguments

[Tab]           Completes the command/word. If the input is ambiguous,
              a second [Tab] gives possible options

/               Move up to base level
..              Move up one level
/command        Use command at the base level

[admin@MikroTik] >
```

> Great you connected! the interface is a bit weird, all commands start with a ``/`` and you use `?` for help within each section. If you didn't manage to connect you're going to need to sort that out before continuing or give up and use a GUI.

Type `/quit` in to the console to exit.

##### Check your OS version

All the code in this repo is hard-coded for version `6.35.2` (which was current at time of writing). If yours is older than that go ahead and upgrade first.

```bash
ssh admin@192.168.88.1 system package update download
```

##### Upload your certificates

You'll need to upload those certificates that we downloaded earlier on to your Mikrotik.

> you'll need to do this for all 3 files, see ./task/cert.install.sh for more info.

```bash
scp ca.crt admin@192.168.88.1:/
scp client.crt admin@192.168.88.1:/
scp client.key admin@192.168.88.1:/
```

```bash
ssh admin@192.168.88.1 certificate import file-name=ca.crt passphrase=\"\"
ssh admin@192.168.88.1 certificate import file-name=client.crt passphrase=\"\"
ssh admin@192.168.88.1 certificate import file-name=client.key passphrase=\"\"
```

We can confirm that worked:

```bash
ssh admin@192.168.88.1 certificate print
```

```bash
Flags: K - private-key, D - dsa, L - crl, C - smart-card-key, A - authority, I - issued, R - revoked, E - expired, T - trusted
 #          NAME                        COMMON-NAME                     SUBJECT-ALT-NAME                                                  FINGERPRINT                    
 0        T ca.crt_0                    Fort-Funston CA                                                                                   12911f9e101be5b3e15cd44e52cc...
 1 K      T client.crt_0                missinglink1                    DNS:missinglink1                                                  8bd36e8431eef6c52151c8400ef0...
```

##### Rename your certificates

This is optional; if this if your first time, best do this so you can follow the rest of the steps:

```bash
ssh admin@192.168.88.1 certificate set ca.crt_0 name=CA
```

```bash
ssh admin@192.168.88.1 certificate set client.crt_0 name=client
```

We can confirm that worked:

```bash
ssh admin@192.168.88.1 certificate print
```

##### Create a PPP profile

This section contains all the details of *how* you will connect to the server, the following worked for me, you may need to change some settings for your specific server configuration:

```bash
ssh admin@192.168.88.1 ppp profile add name=OVPN-client change-tcp-mss=yes only-one=yes use-encryption=required use-mpls=no
```

We can confirm that worked:

```bash
ssh admin@192.168.88.1 ppp profile print
```

```bash
Flags: * - default
 0 * name="default" remote-ipv6-prefix-pool=none use-ipv6=yes use-mpls=default
     use-compression=default use-encryption=default only-one=default
     change-tcp-mss=yes use-upnp=default address-list="" on-up="" on-down=""

 1   name="OVPN-client" remote-ipv6-prefix-pool=none use-ipv6=yes use-mpls=no
     use-compression=default use-encryption=required only-one=yes
     change-tcp-mss=yes use-upnp=default address-list="" on-up="" on-down=""

 2 * name="default-encryption" remote-ipv6-prefix-pool=none use-ipv6=yes
     use-mpls=default use-compression=default use-encryption=yes
     only-one=default change-tcp-mss=yes use-upnp=default address-list=""
     on-up="" on-down=""
```

##### Create an OpenVPN interface

Here we actually create an interface for the VPN connection:

> IMPORTANT!! Change xxx.xxx.xxx.xxx to your own server address (ip address or domain name).

```bash
ssh admin@192.168.88.1 interface ovpn-client add connect-to=xxx.xxx.xxx.xxx add-default-route=no auth=sha1 certificate=client disabled=no user=vpnuser password=vpnpass name=myvpn profile=OVPN-client
```

User/password properties seem to be mandatory on the client even if the server doesn't have `auth-user-pass-verify` enabled.


##### Test the VPN connection

If everything went according to plan you should now be connected:

```bash
ssh admin@192.168.88.1 interface ovpn-client print
```

Note the `'R'` which shows the connection has been established (give it a few seconds):

```bash
Flags: X - disabled, R - running
 0  R name="myvpn" mac-address=FE:EE:75:8F:14:3D max-mtu=1500
      connect-to=xxx.xxx.xxx.xxx port=1194 mode=ip user="vpnuser" password="vpnpass"
      profile=OVPN-client certificate=client auth=sha1 cipher=blowfish128
      add-default-route=no
```

```bash
ssh admin@192.168.88.1 interface ovpn-client monitor 0
```

```bash
status: connected
uptime: 1h35m45s
encoding: BF-128-CBC/SHA1
   mtu: 1500

status: connected
uptime: 1h35m46s
encoding: BF-128-CBC/SHA1
   mtu: 1500
```

##### Configure the firewall

This is explained [in this post](http://wiki.mikrotik.com/wiki/Policy_Base_Routing), basically we define some routes in our local network that **won't** go through the VPN (things in the 10.0.0.0, 172.16.0.0 & 192.168.0.0 ranges) and we add them to a list called `local_traffic`:

```bash
ssh admin@192.168.88.1 ip firewall address-list add address=10.0.0.0/8 disabled=no list=local_traffic
```

```bash
ssh admin@192.168.88.1 ip firewall address-list add address=172.16.0.0/12 disabled=no list=local_traffic
```

```bash
ssh admin@192.168.88.1 ip firewall address-list add address=192.168.0.0/16 disabled=no list=local_traffic
```

Then we set up a `'mangle'` rule which marks packets coming from the local network and destined for the internet with a mark named `vpn_traffic`:

```bash
ssh admin@192.168.88.1 ip firewall mangle add disabled=no action=mark-routing chain=prerouting dst-address-list=\!local_traffic new-routing-mark=vpn_traffic passthrough=yes src-address=192.168.88.2-192.168.88.254
```

##### Configure routing

Next we tell the router that all traffic with the `vpn_traffic` mark should go through the VPN interface:

```bash
ssh admin@192.168.88.1 ip route add disabled=no dst-address=0.0.0.0/0 type=unicast gateway=myvpn routing-mark=vpn_traffic scope=30 target-scope=10
```

##### Configure masquerade

And finally we add a masquerade NAT rule:

```bash
ssh admin@192.168.88.1 ip firewall nat add chain=srcnat src-address=192.168.88.0/24 out-interface=myvpn action=masquerade
```

## Finished!

That's it! your external traffic should now be routed through the VPN.

If this readme helped you out please star the repo; github stars are like crack cocaine to software developers :)

## Credits / Resources

Big thanks to all these people who wrote about this in the past.

- https://lukas.dzunko.sk/index.php/MikrotTik:_OpenVPN
- https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-14-04

## License

```
This work ‘as-is’ we provide.
No warranty express or implied.
  We’ve done our best,
  to debug and test.
Liability for damages denied.

Permission is granted hereby,
to copy, share, and modify.
  Use as is fit,
  free or for profit.
These rights, on this notice, rely.
```
