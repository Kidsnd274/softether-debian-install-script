#!/bin/bash
echo "Please press any key to continue"
read -n 1 -s -r
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
