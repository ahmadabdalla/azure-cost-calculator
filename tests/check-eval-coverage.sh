#!/usr/bin/env bash
# check-eval-coverage.sh
# Usage: check-eval-coverage.sh <service-file-path> [<service-file-path> ...]
#
# For each service reference file, checks whether a happy-path eval task exists.
# A service is covered when at least one task YAML under tests/evals/ is tagged
# with both 'happy-path' and 'service:<service-name>'.
#
# Prints one line per uncovered service: <category>/<service>|<suggested-path>
# Always exits 0.

set -euo pipefail

TASKS_DIR="tests/evals/azure-cost-calculator/tasks"

uncovered=()

for f in "$@"; do
  svc=$(basename "$f" .md)
  category=$(basename "$(dirname "$f")")
  suggested_path="${TASKS_DIR}/${category}/${svc}/"

  # Check if any task YAML has both 'service:<svc>' and 'happy-path' tags
  found=false
  while IFS= read -r task_file; do
    if grep -qe "- happy-path" "$task_file"; then
      found=true
      break
    fi
  done < <(grep -r -l -e "service:${svc}" "$TASKS_DIR" 2>/dev/null || true)

  if [ "$found" = false ]; then
    uncovered+=("${category}/${svc}|${suggested_path}")
  fi
done

if [ ${#uncovered[@]} -gt 0 ]; then
  for item in "${uncovered[@]}"; do
    echo "$item"
  done
fi
