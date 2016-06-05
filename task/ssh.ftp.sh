#!/bin/bash

# upload file via FTP
# http://wiki.mikrotik.com/wiki/Use_SSH_to_execute_commands_(DSA_key_login)

echo "Connecting to Mikrotik via FTP"
echo "[note] the default admin password is blank"

ftp -n <<EOF
open $ADDR
user admin
put ~/.ssh/id_dsa.pub
quit
EOF

echo
echo "Your public key has been uploaded to the Mikrotik"
echo "you must now use the web interface to open a terminal, enter:"
echo
