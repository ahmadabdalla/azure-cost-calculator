# Custom Copilot Coding Agents — Operations Guide

Multi-agent system that gives the Copilot coding agent research-first, consensus-driven workflows for service reference authoring and review.

## Service Reference Authoring Agent

| Item              | Detail                                                                       |
| ----------------- | ---------------------------------------------------------------------------- |
| Orchestrator      | `.github/agents/service-reference.md`                                        |
| Sub-agent (data)  | `.github/agents/pricing-investigator.md`                                     |
| Sub-agent (rules) | `.github/agents/compliance-reviewer.md`                                      |
| Trigger           | Copilot coding agent assigned to an issue                                    |
| Depends on        | `CONTRIBUTING.md`, `docs/TEMPLATE.md`, `tests/Validate-ServiceReference.ps1` |

---

## What it does

When the Copilot coding agent is assigned to a service-reference issue using the `service-reference` custom agent, it runs a multi-agent consensus workflow:

1. **Orchestrator** (`service-reference`) reads the routing map and dispatches four sub-agent invocations independently.
2. **Pricing Investigator A** (`pricing-investigator`, first instance) explores the Azure Retail Prices API, cross-checks Microsoft Learn documentation, and returns a structured **Pricing Investigation Report**.
3. **Pricing Investigator B** (`pricing-investigator`, second instance, identical prompt) independently explores the same API — may discover different meters or interpret results differently.
4. **Pricing Investigator C** (`pricing-investigator`, third instance, identical prompt) provides a third independent view for majority-based consensus.
5. **Compliance Reviewer** (`compliance-reviewer`) reads all rule sources (CONTRIBUTING.md, TEMPLATE.md, schema, shared.md, pitfalls.md), studies category exemplars, and returns a structured **Compliance Contract**.
6. **Orchestrator** compares Reports A, B, and C for majority agreement, dispatches a tiebreaker investigator (using a different coding model) for unresolved disagreements, cross-references the consensus data against the Compliance Contract, writes the service reference file, and runs validation.

### Why multi-agent?

- **Independent views prevent blind spots**: three investigators may explore different search terms and find different meters — disagreement reveals areas needing closer investigation.
- **Majority consensus over speculation**: the orchestrator only writes what a majority (2/3 or 3/3) of investigators agree on. Unresolved disputes trigger a tiebreaker round with a different coding model.
- **Separation of concerns**: data discovery (shell + web) vs rule interpretation (read-only) vs file authoring.

---

## Assignment

### How issues flow to the agent

1. **Triage** — when a new issue is opened, the [issue triage workflow](issue-triage.md) classifies it and applies labels (e.g., `new-service`, `pricing-inaccuracy`).
2. **Maintainer review** — a maintainer reviews the triaged issue and decides whether to assign the Copilot coding agent or wait for a human contributor.
3. **Assignment** — the maintainer assigns the Copilot coding agent to the issue by selecting the `service-reference` custom agent. The agent then runs the multi-agent workflow described below.

### Assignment criteria

- **New service issues** (`new-service` label): Assign the agent when:
  - The contributor did not indicate they want to submit the change themselves, OR
  - The issue has been open without a PR for an extended period
- **Pricing inaccuracy issues** (`pricing-inaccuracy` label): Currently requires manual review — the agent workflow is optimized for new file creation, not updates to existing files.
- **General enhancements** (`enhancement` label): Evaluate case-by-case; most enhancements are not service reference work.

### Contributor self-service

If the issue template's "I would like to submit this change myself" checkbox is checked, the maintainer should allow time for the contributor to open a PR before assigning the agent. If no PR appears within a reasonable timeframe, the maintainer may assign the agent.

---

## Architecture

```
service-reference (orchestrator)
  ├── invokes: pricing-investigator (instance A)
  │     Tools: read, search, execute, web
  │     Output: Pricing Investigation Report A
  │
  ├── invokes: pricing-investigator (instance B)  ← identical prompt
  │     Tools: read, search, execute, web
  │     Output: Pricing Investigation Report B
  │
  ├── invokes: pricing-investigator (instance C)  ← identical prompt
  │     Tools: read, search, execute, web
  │     Output: Pricing Investigation Report C
  │
  ├── invokes: compliance-reviewer
  │     Tools: read, search (no shell, no edit, no web)
  │     Output: Compliance Contract
  │
  ├── orchestrator: compares A vs B vs C → majority agreement
  │     If unresolved disagreements remain:
  │     └── invokes: pricing-investigator (tiebreaker, different coding model)
  │           Scoped to disputed items only
  │           Output: Tiebreaker Report
  │
  └── orchestrator: cross-references consensus against contract →
        writes file → validates
        Tools: read, search, edit, execute, agent, web
```

---

## Prerequisites

| Requirement                      | Notes                                                                                                                                                   |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Copilot coding agent enabled** | The repository must have the Copilot coding agent feature turned on.                                                                                    |
| **PowerShell 7+**                | The agent environment needs `pwsh` to run `Explore-AzurePricing` and `Get-AzurePricing`.                                                                |
| **Network access**               | Scripts call the [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices).               |
| **Issue content**                | Issues should include the Azure service name; the agent reads `skills/azure-cost-calculator/references/service-routing.md` to resolve exact API values. |

---

## How to make changes

### Agent files

| File                                     | Role                                                                                   | Tools                                   |
| ---------------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------- |
| `.github/agents/service-reference.md`    | Orchestrator — dispatches, aggregates, writes                                          | read, search, edit, execute, agent, web |
| `.github/agents/pr-reviewer.md`          | PR review orchestrator — verifies, reviews                                             | read, search, edit, execute, agent, web |
| `.github/agents/pricing-investigator.md` | API investigation sub-agent (invoked ×3 for authoring, ×2 for PR review, + tiebreaker) | read, search, execute, web              |
| `.github/agents/compliance-reviewer.md`  | Rules analysis sub-agent                                                               | read, search                            |

1. Edit the agent file directly.
2. **YAML frontmatter** controls metadata (`name`, `description`, `tools`).
3. **Markdown body** is the agent's prompt (max 30,000 characters per file).
4. Changes take effect on the next agent invocation — versioned by Git commit SHA.
5. Push / open a PR. Profiles are read from the **default branch**.

> **Important:** The agents reference existing repo files (`CONTRIBUTING.md`, `docs/TEMPLATE.md`, etc.) at runtime. If rules change, update those files first — agents read them live, not from a snapshot in the prompt.

### Tool restrictions

Sub-agents use restricted toolsets (principle of least privilege):

- `pricing-investigator` has `execute` for running scripts and `web` for Microsoft Learn cross-checks, but cannot `edit` files. Invoked three times with identical inputs for authoring (majority-based consensus), twice for PR review, plus an optional tiebreaker round with a different coding model for unresolved disputes.
- `compliance-reviewer` has only `read` and `search` — no shell, no editing, no web. All documentation cross-checks come from the pricing investigation reports.
- Only the orchestrators (`service-reference` and `pr-reviewer`) have `edit` and `agent` tools

---

## Relationship to other files

| File                                  | Relationship                                                                                                                                                    |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md` / `CLAUDE.md`             | Repo-level context for all agents; the custom agents complement these with service-reference-specific workflow enforcement.                                     |
| `CONTRIBUTING.md`                     | Contains "The Prompt" workflow; the compliance reviewer reads this to produce its contract. Defines alphabetical ordering rule for routing and catalog entries. |
| `docs/TEMPLATE.md`                    | Template structure; referenced by the compliance reviewer, not duplicated.                                                                                      |
| `tests/Validate-ServiceReference.ps1` | Validation script the orchestrator runs as its final step.                                                                                                      |
| `skills/.../scripts/`                 | Explore/Get-AzurePricing scripts the pricing investigator runs for API discovery.                                                                               |

---

## Troubleshooting

| Symptom                        | Likely cause                                                        | Fix                                                                           |
| ------------------------------ | ------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Agent not appearing            | File not merged to default branch, or filename doesn't end in `.md` | Merge to main; verify paths in `.github/agents/`                              |
| Sub-agent not invoked          | Orchestrator's `tools` list missing `agent` alias                   | Ensure `tools: ["read", "search", "edit", "execute", "agent", "web"]`         |
| Agent not following rules      | Referenced files (`CONTRIBUTING.md`, `TEMPLATE.md`) are out of date | Update upstream files; agents read them at runtime                            |
| Validation failures            | Generated file doesn't match template or has bad data               | Orchestrator should auto-fix; if not, check validation script output          |
| Script execution failures      | Missing PowerShell 7+ or no network access                          | Ensure agent environment has `pwsh` and can reach the Azure Retail Prices API |
| Consensus conflicts unresolved | Sub-agents disagree and orchestrator doesn't arbitrate              | Review orchestrator's Phase 2 conflict resolution logic                       |

---

## PR Reviewer Agent

| Item             | Detail                                                                                     |
| ---------------- | ------------------------------------------------------------------------------------------ |
| Orchestrator     | `.github/agents/pr-reviewer.md`                                                            |
| Sub-agent (data) | `.github/agents/pricing-investigator.md` (invoked ×2, + optional tiebreaker)               |
| Trigger          | Copilot coding agent assigned to review a PR with service reference changes                |
| Depends on       | `CONTRIBUTING.md`, `docs/TEMPLATE.md`, `tests/Validate-ServiceReference.ps1`, GitHub skill |

### What it does

When the Copilot coding agent is assigned to review a PR using the `pr-reviewer` custom agent, it runs a review-focused consensus workflow:

1. **Orchestrator** (`pr-reviewer`) gathers PR metadata (diff, comments, author), creates a dedicated worktree for the PR branch, and identifies changed service reference files.
2. **Pricing Investigator A** (`pricing-investigator`, first instance) independently investigates the Azure Retail Prices API and compares findings against the PR's file content.
3. **Pricing Investigator B** (`pricing-investigator`, second instance, identical prompt) independently performs the same investigation — may discover different discrepancies.
4. **Orchestrator** compares Reports A and B for agreement. If disagreements exist, dispatches a tiebreaker investigator using a different coding model, scoped to the disputed items only.
5. **Orchestrator** runs the validation script, compiles a structured review (blocking issues, warnings, informational), posts it as a PR comment mentioning the author, and cleans up the worktree.

### Why dual investigation?

- **Independent verification**: two investigators may explore different search terms and find different discrepancies — disagreement reveals areas needing closer scrutiny.
- **Consensus over false positives**: only report findings that a majority agrees on, reducing noise in PR reviews.
- **Tiebreaker for disputes**: unresolved disagreements trigger a third investigation with a different coding model, ensuring no contested finding ships without arbitration.

### Architecture

```
pr-reviewer (orchestrator)
  ├── GitHub skill: gather PR metadata, diff, comments
  ├── git worktree: check out PR branch
  │
  ├── invokes: pricing-investigator (instance A)
  │     Tools: read, search, execute, web
  │     Input: service name + file content + PR comments
  │     Output: Pricing Investigation Report A + file discrepancies
  │
  ├── invokes: pricing-investigator (instance B)  ← identical prompt
  │     Tools: read, search, execute, web
  │     Output: Pricing Investigation Report B + file discrepancies
  │
  ├── orchestrator: compares A vs B → agreement/disagreements
  │     If disagreements exist:
  │     └── invokes: pricing-investigator (tiebreaker, different coding model)
  │           Scoped to disputed items only
  │           Output: Tiebreaker Report
  │
  ├── orchestrator: runs validation script on changed files
  │
  ├── orchestrator: compiles review, categorizes by severity
  │     (blocking / warning / info)
  │
  ├── GitHub skill: posts review mentioning @author
  │     If blocking → request changes
  │     If clean    → approve
  │
  └── git worktree remove: cleanup
```

### Trigger & assignment

The `pr-reviewer` agent is designed for PRs that create, update, enhance, or fix service reference files. A maintainer assigns the agent by selecting the `pr-reviewer` custom agent on the PR. It can also be triggered for PRs opened by the `service-reference` agent itself, providing an automated quality gate.

### Troubleshooting

| Symptom                          | Likely cause                                        | Fix                                                                        |
| -------------------------------- | --------------------------------------------------- | -------------------------------------------------------------------------- |
| Agent not appearing              | File not merged to default branch                   | Merge to main; verify `.github/agents/pr-reviewer.md` exists               |
| No service reference files found | PR doesn't change files under `services/`           | Expected — agent posts a skip message and stops                            |
| Worktree creation fails          | Branch not fetched or conflicting worktree exists   | Ensure PR branch is available; remove stale worktrees                      |
| Sub-agent not invoked            | Orchestrator's `tools` list missing `agent`         | Ensure `tools: ["read", "search", "edit", "execute", "agent", "web"]`      |
| gh CLI commands fail             | Agent environment missing `gh` or not authenticated | Ensure GitHub skill prerequisites are met (gh installed and authenticated) |
| Tiebreaker not triggered         | No disagreements between investigators              | Expected — tiebreaker only runs when investigators disagree                |
| Review comment not posted        | GitHub skill PR comment failed                      | Check authentication and PR permissions                                    |
| Worktree not cleaned up          | Error in earlier phase interrupted cleanup          | Manually run `git worktree remove ../pr-review-{N} --force`                |

---

## References

- [Custom agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents) — how to create custom agent profiles
- [Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration) — frontmatter and prompt format
- [Testing custom agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/test-custom-agents) — how to test agent changes
