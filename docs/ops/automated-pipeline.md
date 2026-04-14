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
  -> [AUTO] Trigger (push-triggered debounce): each Copilot push resets
           a 15-minute timer; fires @copilot review comment after
           15 minutes of silence (Copilot idle)
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
  -> [AUTO] Trigger (push-triggered debounce): each Copilot push resets
           a 15-minute timer; fires @copilot review comment after
           15 minutes of silence (Copilot idle)
  -> [AUTO] Copilot: runs service-ref-pr-reviewer, validates, remediates
  -> [USER] Review + merge
```

The manual step exists because new service issues may be claimed by contributors.

---

## Pipeline artifacts

| Artifact                     | Type            | Trigger                                                      | Purpose                                                              |
| ---------------------------- | --------------- | ------------------------------------------------------------ | -------------------------------------------------------------------- |
| `issue-triage-v2.md`         | gh-aw (Copilot) | `issues: [opened]`                                           | Classifies issues, applies labels, assigns Copilot for Fix existing  |
| `trigger-copilot-review.yml` | Standard YAML   | `push: copilot/**` (debounce) + `workflow_dispatch` (manual) | Posts `@copilot` review comment after Copilot goes idle              |
| `service-reference.md`       | Custom agent    | Copilot assigned to issue                                    | Multi-agent consensus workflow for authoring service reference files |
| `service-ref-pr-reviewer.md` | Custom agent    | `@copilot` comment on PR                                     | Dual-investigation review and remediation of service reference PRs   |

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
| `model`        | `claude-opus-4.6`   | Runs Claude Opus 4.6                        |
| `base-branch`  | `dev`               | PR targets `dev` (not `main`)               |

---

## Trigger workflow details

`.github/workflows/trigger-copilot-review.yml` has two jobs with separate trigger paths.

### `debounce` job

Triggered by `push` events to `copilot/**` branches. Only runs when the actor is `Copilot` (the GitHub Copilot coding agent) and none of the pushed commit messages contains `service-ref-pr-reviewer`.

Uses `concurrency: cancel-in-progress: true` scoped to the branch ref as a debounce mechanism: each new Copilot push cancels the previous run and restarts the 15-minute quiet period. Once Copilot stops committing, the timer completes and the review comment is posted.

Steps:
1. Sleep 900 seconds (15-minute quiet period; resets on each new Copilot push via cancellation).
2. Find the Copilot draft PR for this branch.
3. Check idempotency (paginated comment scan for `service-ref-pr-reviewer`).
4. Apply a short random jitter (0-29s) before posting, to reduce duplicate-post risk from near-simultaneous cancellation races.
5. Post `@copilot` review comment via `PIPELINE_GITHUB_TOKEN`.

`timeout-minutes: 25` bounds the job in case of a hung API call or runner issue.

### `manual-trigger` job

Triggered by `workflow_dispatch` only. Accepts a `branch` input (must match `copilot/**`) and posts the review comment without a debounce sleep once the run acquires its concurrency slot. Use this for manual recovery when the push path misses a PR (runner failure, skipped push event).

```bash
gh workflow run trigger-copilot-review.yml --field branch=copilot/fix-storage-ref
```

Steps: validate branch pattern and git ref format, find PR, check idempotency, post comment. `manual-trigger` uses the same per-branch concurrency group as `debounce` (`copilot-quiet-refs/heads/<branch>`) with `cancel-in-progress: false`, serializing runs on the same branch to avoid duplicate-comment races from cancellation timing.

### Commit-message filter

The job `if:` condition filters out pushes when any pushed commit message contains `service-ref-pr-reviewer` (`join(github.event.commits.*.message, ' ')`). The reviewer agent includes this string in its commit messages, so remediation pushes are zero-cost skips (no runner spun up, no 15-minute sleep). This is a dependency: do not edit the reviewer agent's commit messages in a way that removes this substring, or the filter will stop working and remediation pushes will spin runners.

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

- `push` trigger is scoped to `copilot/**` branches. Forks cannot trigger upstream workflows; the residual risk is a collaborator-created branch named `copilot/*`, mitigated by the actor gate.
- Actor gate (`github.actor == 'Copilot'`) on the `debounce` job prevents non-Copilot pushes from running the job.
- All GitHub Actions context values (`github.repository`, `github.ref_name`) are passed through `env:` blocks and referenced as shell variables. No context values are interpolated directly into `run:` script bodies.
- Comment body is hardcoded (not derived from PR content or branch name).
- Workflow-level `permissions: {}` with write only scoped to the job that needs it (`pull-requests: write`).
- No code checkout. The workflow only reads repo metadata and posts a comment. `workflow_dispatch.branch` is user input, but it is validated (`^copilot/.+` plus `git check-ref-format --branch`) and used as a quoted shell variable before `PIPELINE_GITHUB_TOKEN`-authorized calls.

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

# Review trigger push-triggered runs only
gh run list --workflow=trigger-copilot-review.yml --event push --limit 10
```

### Inspecting Copilot agent sessions

After Copilot is assigned to an issue, the session is visible in the GitHub UI under the issue's activity. Look for the Copilot session link showing model, custom agent, duration, and premium request count.

### Common failure modes

| Symptom                                             | Likely cause                                                                    | Fix                                                                                                                   |
| --------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Triage runs but Copilot not assigned                | Agent verification failed (title, Type, or file check)                          | Check agent job logs for which condition was not met                                                                  |
| Copilot assigned but no session starts              | `PIPELINE_GITHUB_TOKEN` expired or lacks permissions                            | Rotate token (see above)                                                                                              |
| Copilot creates PR but no review trigger            | Actor gate evaluated false; commit-message filter matched; actor string changed | Check push event actor via `gh api repos/{owner}/{repo}/events`; check pushed commit messages for filter match         |
| `debounce` job never runs despite Copilot push      | Actor is not `Copilot` or branch does not match `copilot/**`                    | Inspect the workflow run triggered by the push; check `github.actor` value in logs                                    |
| Review trigger posts comment but Copilot ignores it | Comment posted by `github-actions[bot]` instead of user account                 | Verify `PIPELINE_GITHUB_TOKEN` is a user-owned PAT, not `GITHUB_TOKEN`                                                |
| Duplicate review trigger comments                   | Idempotency guard failed (pagination issue or comment body changed)             | Check that `--paginate \| jq -s` pattern is intact and that the comment body still contains `service-ref-pr-reviewer` |
| PR missed by push path (runner failure etc.)        | Transient runner or push event issue                                            | Run `gh workflow run trigger-copilot-review.yml --field branch=copilot/<name>` manually                               |
| MCP servers blocked by policy                       | Copilot CLI version mismatch                                                    | Recompile with latest gh-aw: `gh extension upgrade github/gh-aw && gh aw compile`                                     |
| `markPullRequestReadyForReview` error               | Known platform restriction                                                      | This mutation is blocked for all non-OAuth tokens. The pipeline does not use it; PRs remain as drafts.                |

---

## Design decisions

### Why assignment lives in the triage workflow (not a separate workflow)

Labels applied by `github-actions[bot]` (via `GITHUB_TOKEN`) do not trigger downstream `issues.labeled` workflow runs. This is a deliberate GitHub rule to prevent infinite loops. A separate assign workflow triggered by `issues.labeled` would never fire when triage applies labels. Collapsing assignment into the triage run avoids this restriction entirely.

### Why PRs stay as drafts

The `markPullRequestReadyForReview` GraphQL mutation is blocked for both fine-grained PATs and `GITHUB_TOKEN`. There is no REST API alternative. Only user-level OAuth tokens (classic PATs with `repo` scope, which GitHub is deprecating) can call it. The pipeline works around this by triggering review via `@copilot` comment instead of requiring ready-for-review status.

### Why push-triggered debounce instead of a schedule-only trigger

The original scheduled trigger (every 2 hours) had a worst-case latency of ~5 hours: Copilot works for up to 1 hour, then a 2-hour idle threshold, then up to a 2-hour poll gap (plus platform scheduling variability). The primary contributor is the poll gap, not the idle threshold.

The push-triggered approach eliminates the poll gap entirely. Each Copilot push fires an event, the `concurrency: cancel-in-progress: true` group cancels any in-flight run and resets the quiet period. After 15 minutes of silence (Copilot idle), the review comment posts. Worst case is now ~75 minutes (60-min Copilot work + 15-min quiet period).

There is no scheduled fallback. `workflow_dispatch` is sufficient for manual recovery; push events are reliable and observable. Fewer trigger paths means less surface area to maintain.

### Why the commit-message filter

After the review comment is posted, the reviewer agent runs, produces findings, and commits fixes back to the branch. Each of those commits triggers a push event. Without the filter, remediation pushes would spin a runner, sleep 15 minutes, then exit (no-op, because the idempotency check would catch it). The commit-message filter eliminates that runner cost at the `if:` layer before any runner is allocated.

### Why @copilot comment instead of a gh-aw review workflow

The Copilot coding agent triggered via `@copilot` comment can both review and remediate (commit fixes to the branch). A gh-aw review workflow is read-only with writes limited to safe-outputs (comments and reviews). The `@copilot` approach provides a more complete automated loop.

---

## References

- [issue-triage.md](issue-triage.md): triage workflow ops guide
- [custom-agents.md](custom-agents.md): agent architecture and troubleshooting
- [gh-aw overview](https://github.github.io/gh-aw/introduction/overview/): GitHub Agentic Workflows engine
- [gh-aw assign-to-agent](https://github.github.io/gh-aw/reference/assign-to-copilot/): safe-output for Copilot assignment
- [Copilot coding agent docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents): custom agent configuration
- [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices): the API agents validate against
