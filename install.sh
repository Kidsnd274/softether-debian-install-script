#!/bin/bash

echo Please run as root! Press any key to continue...
read -n 1 -s -r
if [ "$(id -u)" != "0"]; then
  echo "This script must be run as root, run it with sudo" 1>&2
  exit 1
fi

# Make sure you have gcc and other build stuff
apt-get install -y build-essential

# Copies the vpnservice to systemd before changing directory
cp ./vpnserver.service /lib/systemd/system/vpnserver.service

# Grab latest Softether link for Linux x64 from here: http://www.softether-download.com/en.aspx?product=softether
SoftEtherWindowsManagerLatest=$(wget -q -nv -O- https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("windows-x86_x64-intel")) | .browser_download_url')

SoftEtherLinuxLatest=$(wget -q -nv -O- https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("linux-x64-64bit")) | .browser_download_url'| grep vpnserver)

latest_tag_url=$(curl -sI https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest | grep -iE "^Location:"); echo "${latest_tag_url##*/}"
echo "Found $SoftEtherLinuxLatest"
echo "Installing: ${latest_tag_url##*/}"

wget $SoftEtherLinuxLatest

# Extract it. Enter directory and run make and agree to all license agreements:
tar xvf softether-vpnserver-*.tar.gz
cd vpnserver
printf '1\n1\n1\n' | make

# Copy built files into system directory
cd ..
mv vpnserver /usr/local
cd /usr/local/vpnserver/
chmod 600 *
chmod 700 vpncmd
chmod 700 vpnserver

# Start the service
systemctl daemon-reload
systemctl enable vpnserver
systemctl start vpnserver

echo Install complete. This should work fine if there are no errors.
