#!/usr/bin/env bash
# Purpose:  Merge origin/main into the dev branch with automatic conflict-resolution
#           retries, and report the outcome via GITHUB_OUTPUT.
# Inputs:   None (git identity and remote state are assumed to be pre-configured by the
#           workflow checkout step).
# Outputs:  Writes to $GITHUB_OUTPUT:
#             result         = "success" | "conflict"
#             fallback_reason = "none" | "unresolved_conflict" | "push_race" | "fetch_failure"
# Annotations: ::warning:: and ::notice:: written to stdout for GitHub Actions.
# Exit codes:
#   0 = script completed (result may still be "conflict"; caller checks GITHUB_OUTPUT)

set -euo pipefail

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

merge_and_push() {
  local strategy="$1"
  git reset --hard origin/dev
  if [ "$strategy" = "theirs" ]; then
    if ! git merge origin/main --no-edit -X theirs; then
      git merge --abort || true
      return 10
    fi
  else
    if ! git merge origin/main --no-edit; then
      git merge --abort || true
      return 10
    fi
  fi
  if ! git push origin HEAD:dev; then
    return 20
  fi
  return 0
}

result="conflict"
fallback_reason="unresolved_conflict"
for attempt in 1 2 3; do
  if ! git fetch origin main dev; then
    echo "::warning::git fetch failed on attempt ${attempt}; retrying..."
    fallback_reason="fetch_failure"
    continue
  fi

  rc=0
  merge_and_push "normal" || rc=$?
  if [ "$rc" -eq 0 ]; then
    echo "::notice::Back-merge completed using default merge strategy."
    result="success"
    fallback_reason="none"
    break
  fi

  if [ "$rc" -eq 10 ]; then
    echo "::warning::Default merge conflicted on attempt ${attempt}; retrying with '-X theirs' to keep main authoritative for conflicting hunks."
    rc=0
    merge_and_push "theirs" || rc=$?
    if [ "$rc" -eq 0 ]; then
      echo "::notice::Back-merge completed using '-X theirs' conflict resolution."
      result="success"
      fallback_reason="none"
      break
    fi
  fi

  if [ "$rc" -eq 20 ]; then
    echo "::warning::Push rejected on attempt ${attempt} (dev moved). Retrying with latest origin/dev."
    fallback_reason="push_race"
    continue
  fi

  fallback_reason="unresolved_conflict"
  echo "::warning::Back-merge still has unresolved conflicts after automated strategies (rc=${rc})."
  break
done

echo "result=${result}" >> "$GITHUB_OUTPUT"
echo "fallback_reason=${fallback_reason}" >> "$GITHUB_OUTPUT"
