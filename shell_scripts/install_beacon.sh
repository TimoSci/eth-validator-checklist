#!/bin/bash
git clone -b v1.3.8-hotfix+6c0942 --single-branch https://github.com/prysmaticlabs/prysm.git
cd prysm
#
bazel build //beacon-chain:beacon-chain --config=release
bazel build //validator:validator --config=release