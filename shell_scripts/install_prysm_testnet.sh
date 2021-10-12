#!/bin/bash
cd ~
git clone -b v1.3.9 --single-branch https://github.com/prysmaticlabs/prysm.git
cd prysm
#
bazel build //beacon-chain:beacon-chain --config=release
bazel build //validator:validator --coinfig=release