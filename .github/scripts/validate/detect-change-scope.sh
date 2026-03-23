#!/usr/bin/env bash
# ---------------------------------------------------------
# detect-change-scope.sh
# ---------------------------------------------------------
# Compares the PR branch to the target branch and sorts
# changed files into two buckets, writing results to
# $GITHUB_OUTPUT for downstream steps to consume.
#
# Required env vars:
#   DIFF_BASE       - base commit SHA (PR target branch tip)
#   DIFF_HEAD       - head commit SHA (PR branch tip)
#   SERVICES_ROOT   - relative path to the services directory
#   INFRA_PATHS     - space-separated list of infrastructure
#                     paths to check (passed from the workflow
#                     so paths are defined in one place)
#
# Outputs (written to $GITHUB_OUTPUT):
#   infra_changed        - "true" or "false"
#   service_changed      - "true" or "false"
#   service_deleted      - "true" or "false" (deletion-only
#                          PRs: Invoke-Validation skips deleted
#                          paths, so routing-sync still runs)
#   all_changed_files    - newline-separated list of changed
#                          service .md files (only set when
#                          service_changed=true)
# ---------------------------------------------------------

set -euo pipefail

if [ -z "${DIFF_BASE:-}" ]; then
  echo "::error::Required env var DIFF_BASE is not set."
  exit 1
fi
if [ -z "${DIFF_HEAD:-}" ]; then
  echo "::error::Required env var DIFF_HEAD is not set."
  exit 1
fi
if [ -z "${SERVICES_ROOT:-}" ]; then
  echo "::error::Required env var SERVICES_ROOT is not set."
  exit 1
fi
if [ -z "${INFRA_PATHS:-}" ]; then
  echo "::error::Required env var INFRA_PATHS is not set."
  exit 1
fi

# Service .md files added/changed/modified/renamed (NOT deleted).
# git diff is separated from grep so real git failures propagate;
# "|| true" only suppresses grep exit 1 (no match).
diff_output=$(git diff --name-only --diff-filter=ACMR \
  "$DIFF_BASE" "$DIFF_HEAD" \
  -- "$SERVICES_ROOT/")
SERVICE_CHANGED=$(echo "$diff_output" | grep '\.md$' || true)

# Deleted service .md files tracked separately: Invoke-Validation.ps1
# skips deleted paths via Test-Path, so deletion-only PRs must still
# trigger routing-sync via the service_deleted flag.
deleted_output=$(git diff --name-only --diff-filter=D \
  "$DIFF_BASE" "$DIFF_HEAD" \
  -- "$SERVICES_ROOT/")
SERVICE_DELETED=$(echo "$deleted_output" | grep '\.md$' || true)

# Infrastructure files (tests, template, routing, catalog).
# Word-splitting on INFRA_PATHS is intentional; paths are
# owner-controlled values set in the workflow env block.
# shellcheck disable=SC2086
INFRA_CHANGED=$(git diff --name-only --diff-filter=ACMR \
  "$DIFF_BASE" "$DIFF_HEAD" \
  -- $INFRA_PATHS)

if [ -n "$INFRA_CHANGED" ]; then
  echo "infra_changed=true" >> "$GITHUB_OUTPUT"
else
  echo "infra_changed=false" >> "$GITHUB_OUTPUT"
fi

if [ -n "$SERVICE_CHANGED" ]; then
  echo "service_changed=true" >> "$GITHUB_OUTPUT"
  # Random delimiter avoids collisions with file content.
  delimiter="ghout_$(openssl rand -hex 16)"
  echo "all_changed_files<<${delimiter}" >> "$GITHUB_OUTPUT"
  echo "$SERVICE_CHANGED" >> "$GITHUB_OUTPUT"
  echo "${delimiter}" >> "$GITHUB_OUTPUT"
else
  echo "service_changed=false" >> "$GITHUB_OUTPUT"
fi

if [ -n "$SERVICE_DELETED" ]; then
  echo "service_deleted=true" >> "$GITHUB_OUTPUT"
else
  echo "service_deleted=false" >> "$GITHUB_OUTPUT"
fi
