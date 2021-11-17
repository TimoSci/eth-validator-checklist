#!/bin/bash
rake install:prysm:beacon
rake generate:service:prysmbeacon
./deploy_beacon.sh
