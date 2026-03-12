#!/usr/bin/env bash
set -euo pipefail

# Runs the bats unit test suite inside an Ubuntu container.
# Catches Linux-specific issues (e.g. ARG_MAX per-argument limits) that
# do not surface on macOS.
#
# Usage:
#   bash tests/docker/run-tests.sh              # run all bats tests
#   bash tests/docker/run-tests.sh --tap         # TAP output
#   bash tests/docker/run-tests.sh path.bats     # run specific file

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE="azure-cost-testbed"

echo "Building Docker image: $IMAGE"
docker build -t "$IMAGE" "$REPO_ROOT/tests/docker"

echo "Running bats tests on Ubuntu..."
docker run --rm \
    -v "$REPO_ROOT:/repo" \
    "$IMAGE" \
    bash tests/unit/run-bats-tests.sh "$@"
