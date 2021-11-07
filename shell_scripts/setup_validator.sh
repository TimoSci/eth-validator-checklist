#!/bin/bash

sudo useradd --no-create-home --shell /bin/false prysmvalidator

sudo chown -R prysmvalidator:prysmvalidator /var/lib/prysm/validator
sudo chmod 700 /var/lib/prysm/validator