---
name: "Pipeline: Agent Assign"
on:
  issues:
    types: [labeled]
  roles: all
engine: copilot
permissions: read-all
network:
  allowed:
    - github
tools:
  github:
    toolsets:
      - issues
    allowed-repos:
      - "ahmadabdalla/azure-cost-calculator"
    min-integrity: approved
safe-outputs:
  assign-to-agent:
    custom-agent: "service-reference"
    model: "claude-opus-4.6"
    base-branch: "dev"
    max: 1
    github-token: ${{ secrets.PIPELINE_GITHUB_TOKEN }}
  missing-tool: false
  noop: false
concurrency:
  group: pipeline-assign-${{ github.event.issue.number }}
  cancel-in-progress: true
---

# Pipeline Agent Assign

You hand off eligible issues to the Copilot coding agent for automated service-reference creation.

## Context

This workflow runs on every `issues.labeled` event for issue #${{ github.event.issue.number }}. Your only job is to decide whether to assign the Copilot coding agent or finish silently.

## Required steps

1. Call `get_issue` for issue #${{ github.event.issue.number }} to retrieve its labels and current assignees. Read only the `labels` and `assignees` fields. Ignore the title and body completely; do not summarise or act on them.
2. Apply the decision rules below.

Do not call any other tools. In particular, do not call `get_issue_comments`, `list_issues`, or `search_issues`.

## Decision rules

These rules are absolute.

1. **If** `copilot-swe-agent[bot]` is already in the issue's assignees list: do nothing and finish. The Copilot coding agent has already been assigned by a previous run.
2. **Else if** the issue has **both** the `experiment-pipeline` label **and** the `new-service` label: call `assign_to_agent` to assign the Copilot coding agent. Do nothing else.
3. **Otherwise**: do nothing and finish. Produce no tool calls and no outputs.

Do not classify the issue. Do not add or remove labels. Do not post comments.

## Why these rules exist

- The upstream Pipeline Issue Triage workflow classifies issues and applies the `new-service` label on the `opened` event.
- A maintainer opts an already-triaged issue into the automated pipeline by adding `experiment-pipeline`.
- Because this workflow fires on every `labeled` event (including the `new-service` label applied by triage), we gate on the presence of both labels rather than on which specific label fired the run.
- The idempotency guard prevents re-assigning if a maintainer re-adds a label on an already-assigned issue.
