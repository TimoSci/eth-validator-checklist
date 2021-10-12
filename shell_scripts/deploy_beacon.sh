#!/bin/bash
sudo systemctl daemon-reload
sudo systemctl start prysmbeacon
sudo systemctl enable prysmbeacon