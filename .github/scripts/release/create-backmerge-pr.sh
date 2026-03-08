#!/usr/bin/env bash
# Purpose:  Create or update a back-merge pull request from main to dev when the
#           automated merge step was unable to complete directly.
# Inputs:   FALLBACK_REASON = reason the merge fell back (env var, required)
#           RUN_ID          = GitHub Actions run ID used to name the branch (env var, required)
#           GH_TOKEN        = GitHub token with contents:write + pull-requests:write (env var, required)
# Outputs:  None (side-effects: branch pushed, PR created or updated).
# Exit codes:
#   0 = success
#   1 = required environment variable missing

set -euo pipefail

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN environment variable is required"
  exit 1
fi
if [ -z "${FALLBACK_REASON:-}" ]; then
  echo "::error::FALLBACK_REASON environment variable is required"
  exit 1
fi
if [ -z "${RUN_ID:-}" ]; then
  echo "::error::RUN_ID environment variable is required"
  exit 1
fi

existing_pr="$(gh pr list --base dev --state open --search "chore: merge main back to dev after release in:title" --json number --jq '.[0].number')"
if [ -n "$existing_pr" ] && [ "$existing_pr" != "null" ]; then
  branch_name="$(gh pr view "$existing_pr" --json headRefName --jq '.headRefName')"
  echo "::notice::Refreshing existing back-merge PR #$existing_pr on ${branch_name}"
else
  branch_name="backmerge-main-to-dev-${RUN_ID}"
fi

if [ "$FALLBACK_REASON" = "push_race" ]; then
  pr_body="Automated back-merge after release. Back-merge push to \`dev\` failed after retries because \`dev\` changed concurrently. No merge conflict is expected; merge this PR to complete synchronization."
elif [ "$FALLBACK_REASON" = "fetch_failure" ]; then
  pr_body="Automated back-merge after release. The workflow could not fetch the latest branches reliably after retries, so this PR is opened to complete synchronization manually."
else
  pr_body="Automated back-merge after release. Merge conflicts remained after automated strategies. This PR uses a dedicated back-merge branch so conflict resolutions are not committed to \`main\`."
fi

git fetch origin main
git checkout -B "$branch_name" origin/main
git push origin "$branch_name" --force

if [ -n "$existing_pr" ] && [ "$existing_pr" != "null" ]; then
  gh pr edit "$existing_pr" --body "$pr_body"
else
  gh pr create \
    --base dev \
    --head "$branch_name" \
    --title "chore: merge main back to dev after release" \
    --body "$pr_body"
fi
