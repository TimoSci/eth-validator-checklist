#!/bin/bash

curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list

sudo apt update && sudo apt install bazel
sudo apt update && sudo apt full-upgrade
sudo apt update && sudo apt install bazel-3.7.0

sudo apt install -y libtinfo5 # Terminal handling
sudo apt-get install -y libssl-dev # OpenSSL 
sudo apt-get install -y libgmp-dev # GMP source to build BLS