#!/bin/bash
./update_server.sh
#
#install gunpg2 which may be required for Ruby
#
sudo apt-get install gnupg2
#ufw
sudo apt-get install ufw
./ufw_rules.sh
sudo ufw enable
#
./install_geth.sh
./setup_geth.sh
./start_geth.sh
#
./setup_beacon.sh

