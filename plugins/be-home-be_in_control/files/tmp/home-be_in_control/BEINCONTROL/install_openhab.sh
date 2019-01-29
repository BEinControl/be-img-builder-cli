#!/bin/bash

# Add bintray key to atp
#
wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | sudo apt-key add -

# Allow apt to use https protocol
#
sudo apt-get install apt-transport-https

# Register Stable repo with apt
#
echo 'deb https://dl.bintray.com/openhab/apt-repo2 stable main' | sudo tee /etc/apt/sources.list.d/openhab2.list

# Re-sync package index
#
sudo apt-get update

# Install openh2 + addons
#
sudo apt-get install openhab2 openhab2-addons

# Enable autostart on boot
#
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable openhab2.service
