# Automated Service Reference Pipeline: Operations Guide

End-to-end pipeline that automates the lifecycle of service reference issues: from triage to Copilot-authored draft PR to automated pricing review.

| Item             | Detail                                         |
| ---------------- | ---------------------------------------------- |
| Triage workflow  | `.github/workflows/issue-triage-v2.md` (gh-aw) |
| Trigger workflow | `.github/workflows/trigger-copilot-review.yml` |
| Authoring agent  | `.github/agents/service-reference.md`          |
| Review agent     | `.github/agents/service-ref-pr-reviewer.md`    |

---

## How it works

### Fix existing service (fully automatic)

```text
[USER] Open [Service] issue with Type = Fix existing service
  -> [AUTO] Triage: applies pricing-inaccuracy + automatic-existing,
           assigns Copilot with service-reference agent (single run)
  -> [AUTO] Copilot: creates draft PR on dev branch, commits work
  -> [AUTO] Trigger (hourly scheduled idle-check): fires @copilot review
           comment when no Copilot cloud agent run is active on the branch
  -> [AUTO] Copilot: runs service-ref-pr-reviewer, validates against
           live Azure Retail Prices API, remediates if needed
  -> [USER] Review + merge
```

No manual intervention between issue creation and the finished draft PR with review.

### New service (manual assignment)

```text
[USER] Open [Service] issue with Type = New service
  -> [AUTO] Triage: applies new-service + good first issue
  -> [USER] Manually assign Copilot with service-reference agent
  -> [AUTO] Copilot: creates draft PR on dev branch, commits work
  -> [AUTO] Trigger (hourly scheduled idle-check): fires @copilot review
           comment when no Copilot cloud agent run is active on the branch
  -> [AUTO] Copilot: runs service-ref-pr-reviewer, validates, remediates
  -> [USER] Review + merge
```

The manual step exists because new service issues may be claimed by contributors.

---

## Pipeline artifacts

| Artifact                     | Type            | Trigger                                           | Purpose                                                              |
| ---------------------------- | --------------- | ------------------------------------------------- | -------------------------------------------------------------------- |
| `issue-triage-v2.md`         | gh-aw (Copilot) | `issues: [opened]`                                | Classifies issues, applies labels, assigns Copilot for Fix existing  |
| `trigger-copilot-review.yml` | Standard YAML   | `schedule: hourly` + `workflow_dispatch` (manual) | Posts `@copilot` review comment after Copilot goes idle              |
| `service-reference.md`       | Custom agent    | Copilot assigned to issue                         | Multi-agent consensus workflow for authoring service reference files |
| `service-ref-pr-reviewer.md` | Custom agent    | `@copilot` comment on PR                          | Dual-investigation review and remediation of service reference PRs   |

Supporting agents (invoked by the orchestrators, not directly):

| Agent                     | Role                                                                        |
| ------------------------- | --------------------------------------------------------------------------- |
| `pricing-investigator.md` | API investigation sub-agent (x3 for authoring, x2 for review, + tiebreaker) |
| `compliance-reviewer.md`  | Rules analysis sub-agent (authoring only)                                   |

---

## Tokens

The pipeline uses two tokens with distinct scopes:

| Token                   | Type             | Scope                               | Used by                                               | Purpose                                                                                                                                     |
| ----------------------- | ---------------- | ----------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `COPILOT_GITHUB_TOKEN`  | Fine-grained PAT | Copilot Requests                    | gh-aw engine (all gh-aw workflows)                    | Powers the Copilot agent sessions                                                                                                           |
| `PIPELINE_GITHUB_TOKEN` | Fine-grained PAT | Issues: write, Pull Requests: write | Triage (`assign-to-agent`), Trigger (`gh pr comment`) | Assigns Copilot and posts `@copilot` review comments. Read operations work without explicit content permissions because the repo is public. |

### Why two tokens?

- `COPILOT_GITHUB_TOKEN` only needs the Copilot Requests permission. It is shared with the weekly-release and other gh-aw workflows.
- `PIPELINE_GITHUB_TOKEN` needs write access to issues and PRs. It must be a user-owned PAT (not `GITHUB_TOKEN`) for two reasons:
  1. The `assign-to-agent` safe-output requires a PAT to trigger the Copilot coding agent. `GITHUB_TOKEN` cannot do this.
  2. `@copilot` PR comments only trigger the coding agent when posted by a user account. Comments from `github-actions[bot]` (`GITHUB_TOKEN`) are ignored.

### Token owner attribution

Comments and assignments made via `PIPELINE_GITHUB_TOKEN` are attributed to the PAT owner's account (not `github-actions[bot]`). This is expected behavior.

---

## Triage workflow details

See [issue-triage.md](issue-triage.md) for the full triage ops guide. Key pipeline-specific details:

### Assignment conditions

Before calling `assign_to_agent`, the triage agent independently verifies:

1. Issue title matches `[Service]: {name}`.
2. Type field explicitly contains `Fix existing service` (from the template dropdown).
3. The reference file exists at the expected path.

All three must be true. The `max: 1` cap on `assign-to-agent` is enforced at the MCP layer.

### Copilot agent configuration

The `assign-to-agent` safe-output passes three parameters to the Copilot coding agent:

| Parameter      | Value               | Effect                                      |
| -------------- | ------------------- | ------------------------------------------- |
| `custom-agent` | `service-reference` | Loads `.github/agents/service-reference.md` |
| `model`        | `claude-sonnet-4.6` | Runs Claude Sonnet 4.6                      |
| `base-branch`  | `dev`               | PR targets `dev` (not `main`)               |

---

## Trigger workflow details

`.github/workflows/trigger-copilot-review.yml` has two jobs with separate trigger paths.

### `scheduled-idle-check` job

Triggered by `schedule` (every hour on the hour) or by `workflow_dispatch` with `dry_run=true`. Runs as `github-actions[bot]`, which is never subject to the first-time contributor approval gate. The gate fires when the triggering actor is classified as a first-time contributor; GitHub Apps (`app/copilot-swe-agent`) are permanently in that class regardless of merged PRs.

Steps:
1. Look up the Copilot cloud agent workflow ID by name (`"Copilot cloud agent"`) via the Actions API. No hardcoded ID. Fails the job if the workflow is not found rather than silently treating all branches as idle.
2. Query `in_progress` and `queued` runs for that workflow. Merge the two into a deduplicated set of active branch names.
3. List all Copilot (`app/copilot-swe-agent`) draft PRs.
4. For each draft PR, skip if the branch appears in the active set (Copilot still working).
5. Check idempotency (paginated comment scan for `service-ref-pr-reviewer`). Skip if already triggered.
6. Post `@copilot` review comment via `PIPELINE_GITHUB_TOKEN`.

Steps 1-2 use `github.token` (overridden at the step level), not `PIPELINE_GITHUB_TOKEN`. The Actions API requires `actions: read`; `PIPELINE_GITHUB_TOKEN` only carries Issues/PRs write. `PIPELINE_GITHUB_TOKEN` is used only in step 6, where the comment must be attributed to a user account to activate the coding agent.

`timeout-minutes: 10` bounds the job. A `concurrency` group with `cancel-in-progress: false` serializes overlapping runs (unlikely with a 1-hour interval, but safe).

**Dry-run mode** (`dry_run=true`): runs the full idle-check logic (API calls, active-branch cross-reference, idempotency scan) but logs what it would do instead of posting comments. Use this to validate the logic after a code change without waiting for the next hourly tick and without posting real comments on open PRs.

```bash
gh workflow run trigger-copilot-review.yml --field dry_run=true
```

### `manual-trigger` job

Triggered by `workflow_dispatch` only. Accepts a `branch` input (must match `copilot/**`) and posts the review comment immediately. Use this for manual recovery when the scheduled path has not yet fired or was skipped.

```bash
gh workflow run trigger-copilot-review.yml --field branch=copilot/fix-storage-ref
```

Steps: validate branch pattern and git ref format, find PR, check idempotency, post comment. Uses a per-branch concurrency group with `cancel-in-progress: false`, serializing runs on the same branch to avoid duplicate-comment races.

### Idempotency

The job scans all PR comments (paginated, `jq -s` to merge pages) for the string `service-ref-pr-reviewer` before posting. If the string is found, the PR is skipped. The string appears in the comment body because the agent path contains it: `.github/agents/service-ref-pr-reviewer.md`. Do not edit the comment body in a way that removes this substring, or the idempotency check will break.

---

## Security model

### gh-aw triage workflow

- Agent runs in **read-only** mode; all writes go through safe-outputs after threat detection.
- GitHub MCP tools locked to `ahmadabdalla/azure-cost-calculator` via `allowed-repos`.
- `min-integrity: approved` restricts content access to owners, members, and collaborators.
- `assign-to-agent` capped at `max: 1` per run, enforced at MCP layer.
- XPIA (cross-prompt injection attack) protection injected automatically by the gh-aw compiler.

### Trigger workflow

- `schedule` trigger runs as `github-actions[bot]`. No actor-based approval gate applies.
- All GitHub Actions context values (`github.repository`) are passed through `env:` blocks and referenced as shell variables. No context values are interpolated directly into `run:` script bodies.
- Comment body is hardcoded (not derived from PR content or branch name).
- Workflow-level `permissions: {}`. `scheduled-idle-check` holds `contents: read` and `actions: read` only. `manual-trigger` holds `contents: read` only. Neither job holds `pull-requests: write` on `github.token`; all PR writes go through `PIPELINE_GITHUB_TOKEN`.
- No code checkout. The workflow only reads repo metadata via the GitHub API and posts a comment.
- `workflow_dispatch.branch` is user input, validated (`^copilot/.+` plus `git check-ref-format --branch`) and used as a quoted shell variable before any `PIPELINE_GITHUB_TOKEN`-authorized calls.

### Custom agents

- Agents run in the Copilot coding agent sandbox with a network firewall.
- Sub-agents use restricted toolsets (principle of least privilege).
- See [custom-agents.md](custom-agents.md) for agent architecture and tool restrictions.

---

## Prerequisites

| Requirement                         | Notes                                                                                    |
| ----------------------------------- | ---------------------------------------------------------------------------------------- |
| `COPILOT_GITHUB_TOKEN` repo secret  | Fine-grained PAT with Copilot Requests permission                                        |
| `PIPELINE_GITHUB_TOKEN` repo secret | Fine-grained PAT with Issues:write and Pull Requests:write, scoped to this repo          |
| Copilot coding agent enabled        | Repository setting                                                                       |
| Labels                              | `pricing-inaccuracy`, `automatic-existing`, `new-service`, `good first issue` must exist |
| gh-aw CLI                           | `gh extension install github/gh-aw` (compile-time only)                                  |

---

## Making changes

### Triage workflow

See [issue-triage.md: making changes](issue-triage.md#making-changes-to-the-workflow).

### Trigger workflow

Edit `.github/workflows/trigger-copilot-review.yml` directly (standard YAML, no compilation step). Changes take effect after merge to `main` (scheduled triggers run from the default branch).

### Custom agents

Edit agent files in `.github/agents/` directly. Changes take effect on the next agent invocation after merge to `main`. See [custom-agents.md: how to make changes](custom-agents.md#how-to-make-changes).

### Adding new-service automatic assignment

The new-service path currently requires manual Copilot assignment. To automate it:

1. Edit the triage prompt in `issue-triage-v2.md` to call `assign_to_agent` for new-service issues where conditions are met.
2. Update the decision matrix row for "New service | Yes | No" to set "Assign Copilot? = Yes".
3. Recompile with `gh aw compile`.

---

## Rotating PIPELINE_GITHUB_TOKEN

1. Generate a new fine-grained PAT scoped to `ahmadabdalla/azure-cost-calculator` with **Issues: write** and **Pull Requests: write**.
2. Update the repo secret:
   ```bash
   gh secret set PIPELINE_GITHUB_TOKEN
   ```
3. No workflow recompile is needed. Both the triage lock file and the trigger workflow reference the secret by name (`${{ secrets.PIPELINE_GITHUB_TOKEN }}`), so updating the secret value takes effect immediately.

Recompile with `gh aw compile` only if you change the secret **name** or modify the `assign-to-agent` safe-output configuration.

Fine-grained PATs have a configurable expiry (max 1 year). GitHub sends email reminders before expiry. Monitor for `401 Unauthorized` failures in triage and trigger workflow runs as an additional signal.

---

## Monitoring and troubleshooting

### Viewing runs

```bash
# Triage
gh run list --workflow=issue-triage-v2.lock.yml --limit 10

# Review trigger
gh run list --workflow=trigger-copilot-review.yml --limit 10

# Review trigger scheduled runs only
gh run list --workflow=trigger-copilot-review.yml --event schedule --limit 10
```

### Inspecting Copilot agent sessions

After Copilot is assigned to an issue, the session is visible in the GitHub UI under the issue's activity. Look for the Copilot session link showing model, custom agent, and duration.

### Common failure modes

| Symptom                                             | Likely cause                                                                                       | Fix                                                                                                                                             |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Triage runs but Copilot not assigned                | Agent verification failed (title, Type, or file check)                                             | Check agent job logs for which condition was not met                                                                                            |
| Copilot assigned but no session starts              | `PIPELINE_GITHUB_TOKEN` expired or lacks permissions                                               | Rotate token (see above)                                                                                                                        |
| Copilot creates PR but no review trigger            | Scheduled run has not fired yet; Copilot still active on branch; idempotency guard already matched | Wait up to 1hr for the next scheduled run; check `gh run list --workflow=trigger-copilot-review.yml`; use manual trigger for immediate recovery; run `gh workflow run trigger-copilot-review.yml --field dry_run=true` to validate idle-check logic without posting comments |
| Review trigger posts comment but Copilot ignores it | Comment posted by `github-actions[bot]` instead of user account                                    | Verify `PIPELINE_GITHUB_TOKEN` is a user-owned PAT, not `GITHUB_TOKEN`                                                                          |
| Duplicate review trigger comments                   | Idempotency guard failed (pagination issue or comment body changed)                                | Check that `--paginate \| jq -s` pattern is intact and that the comment body still contains `service-ref-pr-reviewer`                           |
| PR missed by scheduled run (tick delayed or skipped) | Copilot reported active at tick time; platform scheduling delay                                   | Wait for next hourly tick; use manual trigger: `gh workflow run trigger-copilot-review.yml --field branch=copilot/<name>`                       |
| MCP servers blocked by policy                       | Copilot CLI version mismatch                                                                       | Recompile with latest gh-aw: `gh extension upgrade github/gh-aw && gh aw compile`                                                               |
| `markPullRequestReadyForReview` error               | Known platform restriction                                                                         | This mutation is blocked for all non-OAuth tokens. The pipeline does not use it; PRs remain as drafts.                                          |

---

## Design decisions

### Why assignment lives in the triage workflow (not a separate workflow)

Labels applied by `github-actions[bot]` (via `GITHUB_TOKEN`) do not trigger downstream `issues.labeled` workflow runs. This is a deliberate GitHub rule to prevent infinite loops. A separate assign workflow triggered by `issues.labeled` would never fire when triage applies labels. Collapsing assignment into the triage run avoids this restriction entirely.

### Why PRs stay as drafts

The `markPullRequestReadyForReview` GraphQL mutation is blocked for both fine-grained PATs and `GITHUB_TOKEN`. There is no REST API alternative. Only user-level OAuth tokens (classic PATs with `repo` scope, which GitHub is deprecating) can call it. The pipeline works around this by triggering review via `@copilot` comment instead of requiring ready-for-review status.

### Why scheduled idle-check instead of push-triggered debounce

Push-triggered workflows with `github.actor == 'Copilot'` (i.e. `app/copilot-swe-agent` as the triggering actor) are blocked by GitHub's first-time contributor approval gate. GitHub Apps are permanently classified as first-time contributors regardless of merged PRs. Changing the trigger type (push, pull_request, workflow_run) does not help: the gate is on the actor, not the event. Only triggers whose actor is `github-actions[bot]` -- schedule and repository_dispatch -- bypass the gate.

The scheduled approach queries the Copilot cloud agent workflow API directly to detect whether Copilot is still active on a branch (`in_progress` or `queued` runs). This gives an accurate idle signal without relying on a timer proxy. Worst-case latency is up to 1 hour (next scheduled tick after Copilot goes idle), which is acceptable for this pipeline.

### Why @copilot comment instead of a gh-aw review workflow

The Copilot coding agent triggered via `@copilot` comment can both review and remediate (commit fixes to the branch). A gh-aw review workflow is read-only with writes limited to safe-outputs (comments and reviews). The `@copilot` approach provides a more complete automated loop.

---

## Experiments

Historical record of research, experiments, and design decisions. Issues and PRs are linked for full context.

| Issue                                                                                                                                                        | PR                                                                     | Status | Summary                                                                                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [#732: Improve PR review automation: second-pass nudge and CodeRabbit trigger diagnostics](https://github.com/ahmadabdalla/azure-cost-calculator/issues/732) | [#749](https://github.com/ahmadabdalla/azure-cost-calculator/pull/749) | Merged | Investigated push-triggered debounce, hit approval-gate regression; replaced with API-backed scheduled idle-check that queries Copilot cloud agent runs directly. Validated end-to-end on #752. |

---

## References

- [issue-triage.md](issue-triage.md): triage workflow ops guide
- [custom-agents.md](custom-agents.md): agent architecture and troubleshooting
- [gh-aw overview](https://github.github.io/gh-aw/introduction/overview/): GitHub Agentic Workflows engine
- [gh-aw assign-to-agent](https://github.github.io/gh-aw/reference/assign-to-copilot/): safe-output for Copilot assignment
- [Copilot coding agent docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents): custom agent configuration
- [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices): the API agents validate against
