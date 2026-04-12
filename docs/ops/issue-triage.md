# Issue Triage Automation: Operations Guide

Automated triage of newly opened issues using [GitHub Agentic Workflows (gh-aw)](https://github.com/github/gh-aw) with the **Copilot** engine. For "Fix existing service" issues, the triage workflow also assigns the Copilot coding agent automatically.

| Item            | Detail                                        |
| --------------- | --------------------------------------------- |
| Workflow source | `.github/workflows/issue-triage-v2.md`        |
| Compiled lock   | `.github/workflows/issue-triage-v2.lock.yml`  |
| Action pins     | `.github/aw/actions-lock.json`                |
| Engine          | `copilot` (GitHub Copilot)                    |
| Trigger         | `on: issues [opened]` (default branch only)   |

---

## What it does

When a new issue is opened the workflow:

1. **Sanitises** the issue body (strips @-mentions, URIs, prompt-injection attempts).
2. Runs the Copilot agent in **read-only** mode to classify the issue.
3. **Applies up to 2 labels** from an allow-list.
4. **Posts at most 1 comment** guiding the contributor.
5. **Assigns the Copilot coding agent** (at most once) for "Fix existing service" issues where the reference file exists.

The agent never closes, locks, transfers, or removes labels from issues.

### Decision matrix (service-reference issues)

The catalog (`docs/service-catalog.md`) lists all services. The routing map contains implemented services. A service in the catalog but not in the routing map is pending implementation.

| Type         | In routing map? | File exists? | Labels                                     | Assign Copilot? | Action                                    |
| ------------ | --------------- | ------------ | ------------------------------------------ | ---------------- | ----------------------------------------- |
| New service  | Yes             | No           | `new-service`, `good first issue`          | No               | Welcome; point to CONTRIBUTING.md         |
| New service  | Yes             | Yes          | `duplicate`                                | No               | Explain file exists; suggest fix issue    |
| New service  | No (in catalog) | No           | `new-service`, `good first issue`          | No               | Pending service; add routing entry in PR  |
| New service  | No (not found)  | -            | `needs-info`                               | No               | Ask for exact `serviceName` from API      |
| Fix existing | -               | Yes          | `pricing-inaccuracy`, `automatic-existing` | **Yes**          | Assign Copilot with `service-reference` agent |
| Fix existing | -               | No           | `needs-info`                               | No               | Ask to clarify service name               |

### Copilot assignment conditions

Before the agent calls `assign_to_agent`, it must independently verify all three conditions:

1. The issue title matches `[Service]: {name}`.
2. The **Type** field explicitly contains `Fix existing service` (from the dropdown, not inferred).
3. The reference file exists at the expected path.

If any condition is not met, the agent skips assignment. The `max: 1` cap on `assign-to-agent` is enforced at the MCP layer.

### Label allow-list

`new-service` · `pricing-inaccuracy` · `automatic-existing` · `service-update` · `needs-info` · `duplicate` · `good first issue` · `question` · `invalid` · `enhancement`

---

## Prerequisites

| Requirement                                | Notes                                                                                                                                      |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **`COPILOT_GITHUB_TOKEN`** repo secret     | Fine-grained PAT with the **Copilot Requests** account permission. Powers the Copilot engine.                                              |
| **`PIPELINE_GITHUB_TOKEN`** repo secret    | Fine-grained PAT with **Issues: write** and **Pull Requests: write**. Powers the `assign-to-agent` safe-output. See [token details](automated-pipeline.md#tokens). |
| **Labels**                                 | `new-service`, `pricing-inaccuracy`, `automatic-existing`, `service-update` must exist in the repo (others are GitHub defaults).            |
| **gh-aw CLI**                              | Installed via `gh extension install github/gh-aw`. Only needed for compiling changes, not at runtime.                                      |

---

## Making changes to the workflow

> **Never manually edit** `issue-triage-v2.lock.yml` or `actions-lock.json`; they are overwritten on every compile.

1. Edit `.github/workflows/issue-triage-v2.md`.
2. Compile:
   ```bash
   gh aw compile
   ```
3. Commit **both** the `.md` and the regenerated `.lock.yml` (and `actions-lock.json` if changed).
4. Push / open a PR. The workflow only runs from the **default branch**, so changes take effect after merge.

---

## Rotating tokens

### COPILOT_GITHUB_TOKEN

1. Generate a new fine-grained PAT with the **Copilot Requests** account permission.
2. Update the repo secret:
   ```bash
   gh secret set COPILOT_GITHUB_TOKEN
   ```
3. No workflow recompile needed.

### PIPELINE_GITHUB_TOKEN

See [automated-pipeline.md: token rotation](automated-pipeline.md#rotating-pipeline_github_token).

---

## Monitoring and troubleshooting

### Viewing runs

```bash
gh run list --workflow=issue-triage-v2.lock.yml --limit 10
```

### Inspecting a failed run

```bash
gh run view <run-id> --log-failed
```

### Common failure modes

| Symptom                                          | Likely cause                                                            | Fix                                                                                  |
| ------------------------------------------------ | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Workflow never triggers                          | Edited `.md` but forgot to compile, or changes not on default branch    | Run `gh aw compile`, merge to main                                                   |
| `401 Unauthorized` in agent job                  | `COPILOT_GITHUB_TOKEN` expired or revoked                               | Rotate the PAT (see above)                                                           |
| Agent applies wrong labels                       | Classification prompt needs tuning                                      | Edit the Decision Matrix in `issue-triage-v2.md`, recompile                          |
| Agent leaves no comment                          | Issue matched "spam / invalid" path, or `add-comment` limit already hit | Check the agent job logs for reasoning                                               |
| Copilot not assigned on Fix existing issue       | Agent verification failed on one of the three conditions                | Check agent logs; verify title, Type field, and file path                            |
| Copilot assigned but no session starts           | `PIPELINE_GITHUB_TOKEN` expired or lacks required permissions           | Rotate; needs Issues:write and Pull Requests:write                                   |
| MCP servers blocked by policy                    | Copilot CLI version mismatch (seen with CLI v1.0.22)                    | Recompile with latest gh-aw (`gh extension upgrade github/gh-aw && gh aw compile`)   |
| Confused `pricing-inaccuracy` / `service-update` | Both relate to existing references but have different scopes            | `pricing-inaccuracy` = wrong pricing data (Fix existing); `service-update` = structural improvements (improvement template) |

### Job architecture

The compiled lock file produces the standard gh-aw job chain:

```
pre_activation -> activation -> agent -> detection -> safe_outputs -> conclusion
```

- **pre_activation**: Validates trigger conditions and sets up the workflow context.
- **activation**: Sanitises issue content into `steps.sanitized.outputs.text`.
- **agent**: Copilot reads the sanitised content (read-only, no write permissions).
- **detection**: Threat-scans the agent output.
- **safe_outputs**: Writes labels, comment, and Copilot assignment to the issue (only job with write access).
- **conclusion**: Reports final status.

---

## Upgrading gh-aw

```bash
gh extension upgrade github/gh-aw
gh aw compile
```

Commit the updated lock files after upgrading.

---

## References

- [gh-aw overview](https://github.github.io/gh-aw/introduction/overview/): GitHub Agentic Workflows engine
- [IssueOps pattern](https://github.github.io/gh-aw/patterns/issueops/): the trigger pattern this workflow uses
- [gh-aw assign-to-agent](https://github.github.io/gh-aw/reference/assign-to-copilot/): safe-output for Copilot assignment
- [Automated pipeline ops doc](automated-pipeline.md): full pipeline architecture and token management
- [service-routing.md](../../skills/azure-cost-calculator/references/service-routing.md): service eligibility map queried by the agent
- [service-catalog.md](../../docs/service-catalog.md): full service catalog including pending services
