#!/bin/bash
sudo systemctl daemon-reload
sudo systemctl start prysmvalidator
sudo systemctl enable prysmvalidator