#!/bin/bash
./update_server.sh
./setup_server
#
# Configure ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
./ufw_rules.sh
sudo ufw enable
#
# Install and deploy geth
./install_and_deploy_geth.sh
#
# Install and deploy beacon
./install_and_deploy_beacon.sh
