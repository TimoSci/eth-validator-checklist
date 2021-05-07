#!/bin/bash
./update_server.sh
#ufw
sudo apt-get install ufw
./ufw_rules.sh
sudo ufw enable
#
./install_geth.sh
./setup_geth.sh
./setup_beacon.sh

