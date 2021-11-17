#!/bin/bash
./update_server.sh
#
#install gunpg2 which may be required for Ruby
#
sudo apt-get install gnupg2
#
# Configure ufw
sudo apt-get install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
./ufw_rules.sh
sudo ufw enable
#
# Install and deploy geth
./install_geth.sh
./setup_geth.sh
rake generate:service:geth
./deploy_geth.sh
sudo systemctl enable geth
#
# Install and deploy beacon
rake install:prysm:beacon
rake generate:service:prysmbeacon
./deploy_beacon.sh
