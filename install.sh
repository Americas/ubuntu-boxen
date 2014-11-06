#!/bin/bash

echo "This script requires root privileges, you will be asked your sudo password"


# Setup PuppetLabs repository
echo -e "Getting PuppetLabs Source"
DISTRO=$(grep DISTRIB_CODENAME /etc/lsb-release | awk -F= '{print $2}')
wget -q https://apt.puppetlabs.com/puppetlabs-release-$DISTRO.deb
sudo dpkg -i puppetlabs-release-$DISTRO.deb
echo -e "Running apt-get update"
sudo apt-get update -y -qq

# Install puppet without the agent init script
echo -e "Installing Puppet"
sudo apt-get install git puppet-common hiera -y -qq

# Download uboxen code
echo -e "Fetching uBoxen"
cd /opt
[ ! -d /opt/ubuntu-boxen ] && sudo git clone https://github.com/Americas/ubuntu-boxen.git

sudo puppet resource file /usr/local/bin/uboxen ensure=link target=/opt/ubuntu-boxen/uboxen

for f in `ls /opt/ubuntu-boxen/manifests`; do
   sudo puppet resource file /etc/puppet/manifests/$f ensure=link target=/opt/ubuntu-boxen/manifests/$f;
done

# Finish
echo -e "\n\nInstallation ended successfully (I hope).\n\nEnjoy Ubuntu Boxen running 'uboxen' at your shell prompt"


