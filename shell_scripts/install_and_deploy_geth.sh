#!/bin/bash
./install_geth.sh
./setup_geth.sh
rake generate:service:geth
./deploy_geth.sh