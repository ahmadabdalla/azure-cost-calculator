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
#                     (e.g. skills/azure-cost-calculator/references/services)
#
# Outputs (written to $GITHUB_OUTPUT):
#   infra_changed        - "true" or "false"
#   service_changed      - "true" or "false"
#   all_changed_files    - newline-separated list of changed service .md
#                          files (only set when service_changed=true)
# ---------------------------------------------------------

set -euo pipefail

# --- Validate required env vars ---
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

# List .md files added/changed/modified/renamed/deleted under services/
# "|| true" prevents an error when nothing matches.
SERVICE_CHANGED=$(git diff --name-only --diff-filter=ACMRD \
  "$DIFF_BASE" "$DIFF_HEAD" \
  -- "$SERVICES_ROOT/" \
  | grep '\.md$' || true)

# List any changed infrastructure files
INFRA_CHANGED=$(git diff --name-only --diff-filter=ACMR \
  "$DIFF_BASE" "$DIFF_HEAD" \
  -- 'tests/' \
     'docs/TEMPLATE.md' \
     'skills/azure-cost-calculator/references/service-routing.md' \
     'docs/service-catalog.md' \
  || true)

# Write results so the next steps can read them.
# "-n" means "not empty".
if [ -n "$INFRA_CHANGED" ]; then
  echo "infra_changed=true" >> "$GITHUB_OUTPUT"
else
  echo "infra_changed=false" >> "$GITHUB_OUTPUT"
fi

if [ -n "$SERVICE_CHANGED" ]; then
  echo "service_changed=true" >> "$GITHUB_OUTPUT"
  # Pass the file list as a multi-line output.
  echo "all_changed_files<<EOF" >> "$GITHUB_OUTPUT"
  echo "$SERVICE_CHANGED" >> "$GITHUB_OUTPUT"
  echo "EOF" >> "$GITHUB_OUTPUT"
else
  echo "service_changed=false" >> "$GITHUB_OUTPUT"
fi
