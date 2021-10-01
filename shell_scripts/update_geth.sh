
#!/bin/bash
sudo apt-get update
sudo systemctl stop geth
sudo apt-get upgrade geth
sudo systemctl start geth
