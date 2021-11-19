#!/bin/bash

curl https://sh.rustup.rs -sSf | sh
sudo apt install clang pkg-config file make cmake
sudo apt install yasm

# download OpenEthereum code
git clone https://github.com/openethereum/openethereum
cd openethereum

# build in release mode
cargo build --release --features final


wget https://dl.grafana.com/enterprise/release/grafana-enterprise-8.2.3.linux-amd64.tar.gz
tar -zxvf grafana-enterprise-8.2.3.linux-amd64.tar.gz