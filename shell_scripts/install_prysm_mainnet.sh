#!/bin/bash
curl -LO https://github.com/prysmaticlabs/prysm/releases/download/v1.3.9/beacon-chain-v1.3.9-linux-amd64
curl -LO https://github.com/prysmaticlabs/prysm/releases/download/v1.3.9/validator-v1.3.9-linux-amd64


mv beacon-chain-v1.0.0-linux-amd64 beacon-chain
mv validator-v1.0.0-linux-amd64 validator

chmod +x beacon-chain
chmod +x validator

sudo cp beacon-chain /usr/local/bin
sudo cp validator /usr/local/bin