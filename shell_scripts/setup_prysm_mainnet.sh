#!/bin/bash

sudo useradd --no-create-home --shell /bin/false prysmbeacon

sudo mkdir -p /var/lib/prysm/beacon
sudo chown -R prysmbeacon:prysmbeacon /var/lib/prysm/beacon
sudo chmod 700 /var/lib/prysm/beacon
