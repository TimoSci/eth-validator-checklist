#!/bin/bash
sudo systemctl daemon-reload
sudo systemctl start geth
sudo systemctl enable geth