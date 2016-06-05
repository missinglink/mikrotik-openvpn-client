#!/bin/bash

# update all packages
# http://wiki.mikrotik.com/wiki/Manual:System/Packages
# https://www.mikrotik.com/documentation/manual_2.5/Basic/Packages.html

VERSION="6.35.2"
URL="http://download2.mikrotik.com/routeros/$VERSION/all_packages-mipsbe-$VERSION.zip"

echo "[info] downloading packages"
rm -r packages &>/dev/null; mkdir packages; cd packages
rm packages.zip 2>/dev/null
wget -q $URL -O packages.zip
unzip packages.zip; rm packages.zip

# copy files to routerboard
for f in *.npk
do
	ssh_push $f "/"
done

cd ..

task "Reboot", "task/reboot.sh"
