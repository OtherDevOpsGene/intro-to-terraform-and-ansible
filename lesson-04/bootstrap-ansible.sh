#!/bin/bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# Quietly install some packages
sudo apt-get -qq -o=Dpkg::Use-Pty=0 update
sudo apt-get -qq -o=Dpkg::Use-Pty=0 -y install python3 python3-pip

# Install Ansible
python3 -m pip install --progress-bar off --user ansible
