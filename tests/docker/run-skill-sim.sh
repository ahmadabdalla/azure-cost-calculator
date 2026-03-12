#!/usr/bin/env bash
set -euo pipefail

# Simulates the end-user skill install experience on Ubuntu.
# Creates a fresh workspace inside the container, installs the published
# skill from main via npx, then drops into an interactive shell.
#
# Note: this installs the published skill from the main branch — not local
# changes. To test local scripts against Linux, use run-tests.sh instead.
#
# Usage:
#   bash tests/docker/run-skill-sim.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE="azure-cost-testbed"

echo "Building Docker image: $IMAGE"
docker build -t "$IMAGE" "$REPO_ROOT/tests/docker"

echo "Starting skill simulation environment..."
docker run --rm -it \
    "$IMAGE" \
    bash -c "
        mkdir -p /workspace && cd /workspace &&
        git init -q &&
        npx --yes skills add ahmadabdalla/azure-cost-calculator-skill &&
        echo '' &&
        echo 'Skill installed. Skill files are in .claude/skills/' &&
        echo 'Scripts are in .claude/skills/azure-cost-calculator/scripts/' &&
        echo '' &&
        exec bash
    "
