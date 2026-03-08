#!/usr/bin/env bash
# ---------------------------------------------------------
# install-bats.sh
# ---------------------------------------------------------
# Installs Bash test dependencies for the bats-core unit
# test job:
#   - bats-core  (Bash Automated Testing System, via npm)
#   - jq         (JSON processor, via apt-get)
# ---------------------------------------------------------

set -euo pipefail

sudo npm install -g bats@1.11.1
sudo apt-get update -qq && sudo apt-get install -y -qq jq

bats --version
