#!/bin/bash

# rules for ssh
sudo ufw allow 22

# rules for geth
sudo ufw allow 30303

# rules for prysm
sudo ufw allow 13000/tcp
sudo ufw allow 12000/udp

# rules for grafana
sudo ufw allow 3000/tcp

# rules for prometheus
sudo ufw allow 9090/tcp
