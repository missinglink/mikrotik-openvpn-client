#!/bin/bash

# install certificates from ./cert

echo "[info] installing certificates from ./cert"

if [[ -d "cert" ]]; then
  cd cert
  # copy files to routerboard
  for f in *
  do
  	ssh_push $f "/"
    echo "importing $f"
    ssh_eval "certificate import file-name=$f passphrase=\"\""
  done
  cd ..
else
  echo "[error] directory ./cert does not exist"
fi

# rename certs?
ssh_eval "certificate set ca.crt_0 name=CA"
ssh_eval "certificate set client.crt_0 name=client"
