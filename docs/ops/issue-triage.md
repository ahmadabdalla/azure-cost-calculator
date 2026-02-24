# Issue Triage Automation - Operations Guide

Automated triage of newly opened issues using [GitHub Agentic Workflows (gh-aw)](https://github.com/github/gh-aw) with the **Copilot** engine.

| Item              | Detail                                                                         |
| ----------------- | ------------------------------------------------------------------------------ |
| Original issue    | [#122](https://github.com/ahmadabdalla/azure-cost-calculator-skill/issues/122) |
| Implementation PR | [#125](https://github.com/ahmadabdalla/azure-cost-calculator-skill/pull/125)   |
| Workflow source   | `.github/workflows/issue-triage.md`                                            |
| Compiled lock     | `.github/workflows/issue-triage.lock.yml`                                      |
| Action pins       | `.github/aw/actions-lock.json`                                                 |
| Engine            | `copilot` (GitHub Copilot)                                                     |
| Trigger           | `on: issues [opened]` (default branch only)                                    |

---

## What it does

When a new issue is opened the workflow:

1. **Sanitises** the issue body (strips @-mentions, URIs, prompt-injection attempts).
2. Runs the Copilot agent in **read-only** mode to classify the issue.
3. **Applies up to 2 labels** from an allow-list.
4. **Posts at most 1 comment** guiding the contributor.

The agent never closes, locks, transfers, or removes labels from issues.

### Decision matrix (service-reference issues)

The catalog (`docs/service-catalog.md`) lists all services. The routing map contains implemented services. A service in the catalog but not in the routing map is pending implementation.

| Type         | In routing map? | File exists? | Labels                            | Action                                    |
| ------------ | --------------- | ------------ | --------------------------------- | ----------------------------------------- |
| New service  | Yes             | No           | `new-service`, `good first issue` | Welcome; point to CONTRIBUTING.md         |
| New service  | Yes             | Yes          | `duplicate`                       | Explain file exists; suggest fix issue    |
| New service  | No (in catalog) | No           | `new-service`, `good first issue` | Pending service; add routing entry in PR  |
| New service  | No (not found)  | -            | `needs-info`                      | Ask for exact `serviceName` from API      |
| Fix existing | -               | Yes          | `pricing-inaccuracy`              | Suggest verifying with `Get-AzurePricing` |
| Fix existing | -               | No           | `needs-info`                      | Ask to clarify service name               |

### Label allow-list

`new-service` · `pricing-inaccuracy` · `service-update` · `needs-info` · `duplicate` · `good first issue` · `question` · `invalid` · `enhancement`

---

## Prerequisites

| Requirement                            | Notes                                                                                                                                  |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **`COPILOT_GITHUB_TOKEN`** repo secret | Fine-grained PAT scoped to this repo with the **Copilot Requests** account permission. Does not need "All public repositories" access. |
| **Labels**                             | `new-service`, `pricing-inaccuracy`, `service-update` must exist in the repo (the others are GitHub defaults).                         |
| **gh-aw CLI**                          | Installed via `gh extension install github/gh-aw`. Only needed for compiling changes - not at runtime.                                 |

---

## Making changes to the workflow

> **Never manually edit** `issue-triage.lock.yml` or `actions-lock.json` - they are overwritten on every compile.

1. Edit `.github/workflows/issue-triage.md`.
2. Compile:
   ```bash
   gh aw compile
   ```
3. Commit **both** the `.md` and the regenerated `.lock.yml` (and `actions-lock.json` if changed).
4. Push / open a PR. The workflow only runs from the **default branch**, so changes take effect after merge.

---

## Rotating the PAT

1. Generate a new fine-grained PAT with the **Copilot Requests** account permission.
2. Update the repo secret:
   ```bash
   gh secret set COPILOT_GITHUB_TOKEN
   ```
3. No workflow recompile is needed - the secret name hasn't changed.

---

## Monitoring & troubleshooting

### Viewing runs

```bash
gh run list --workflow=issue-triage.lock.yml --limit 10
```

### Inspecting a failed run

```bash
gh run view <run-id> --log-failed
```

### Common failure modes

| Symptom                                          | Likely cause                                                            | Fix                                                                                                                                                                           |
| ------------------------------------------------ | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Workflow never triggers                          | Edited `.md` but forgot to compile, or changes not on default branch    | Run `gh aw compile`, merge to main                                                                                                                                            |
| `401 Unauthorized` in agent job                  | `COPILOT_GITHUB_TOKEN` expired or revoked                               | Rotate the PAT (see above)                                                                                                                                                    |
| Agent applies wrong labels                       | Classification prompt needs tuning                                      | Edit the Decision Matrix in `issue-triage.md`, recompile                                                                                                                      |
| Agent leaves no comment                          | Issue matched "spam / invalid" path, or `add-comment` limit already hit | Check the agent job logs for reasoning                                                                                                                                        |
| Confused `pricing-inaccuracy` / `service-update` | Both relate to existing references but have different scopes            | `pricing-inaccuracy` = wrong pricing data (service-reference template, "Fix existing service"); `service-update` = structural/non-pricing improvements (improvement template) |

### Job architecture

The compiled lock file produces five jobs:

```
pre_activation → activation → agent → detection → safe_outputs → conclusion
```

- **activation**: Sanitises issue content into `needs.activation.outputs.text`.
- **agent**: Copilot reads the sanitised content (read-only, no write permissions).
- **detection**: Threat-scans the agent output.
- **safe_outputs**: Writes labels and comment to the issue (only job with write access).
- **conclusion**: Reports final status.

---

## Upgrading gh-aw

```bash
gh extension upgrade github/gh-aw
gh aw compile          # recompile to pick up new action versions
```

Commit the updated lock files after upgrading.

---

## References

- [gh-aw overview](https://github.github.io/gh-aw/introduction/overview/) - GitHub Agentic Workflows engine
- [IssueOps pattern](https://github.github.io/gh-aw/patterns/issueops/) - the trigger pattern this workflow uses
- [service-routing.md](../../skills/azure-cost-calculator/references/service-routing.md) - service eligibility map queried by the agent (implemented services)
- [service-catalog.md](../../docs/service-catalog.md) - full service catalog including pending services
