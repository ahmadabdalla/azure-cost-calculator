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

REPO_ROOT="$(git rev-parse --show-toplevel)"
TASKS_DIR="${REPO_ROOT}/tests/evals/azure-cost-calculator/tasks"

uncovered=()

for f in "$@"; do
  # Skip paths that no longer exist (e.g. a file deleted or renamed in this
  # change set); coverage only applies to service files present on disk.
  [ -f "$f" ] || continue

  svc=$(basename "$f" .md)
  category=$(basename "$(dirname "$f")")
  suggested_path="${TASKS_DIR}/${category}/${svc}/"

  # Services with hasMeters: false have no pricing API data and are exempt from
  # the happy-path requirement per docs/ops/evals.md exception rules.
  if grep -qE "^hasMeters:[[:space:]]*false" "$f" 2>/dev/null; then
    continue
  fi

  # Check if any task YAML has both 'service:<svc>' and 'happy-path' tags
  found=false
  while IFS= read -r task_file; do
    if grep -qEe "^[[:space:]]*- happy-path[[:space:]]*$" "$task_file"; then
      found=true
      break
    fi
  done < <(find "$TASKS_DIR" -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 \
    | xargs -0 -r grep -l -E "^[[:space:]]*-[[:space:]]*service:${svc}[[:space:]]*$" 2>/dev/null || true)

  if [ "$found" = false ]; then
    uncovered+=("${category}/${svc}|${suggested_path}")
  fi
done

if [ ${#uncovered[@]} -gt 0 ]; then
  for item in "${uncovered[@]}"; do
    echo "$item"
  done
fi
