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
concurrency:
  group: pipeline-assign-${{ github.event.issue.number }}
  cancel-in-progress: true
---

# Pipeline Agent Assign

You hand off eligible issues to the Copilot coding agent for automated service-reference creation.

## Context

This workflow runs on every `issues.labeled` event for issue #${{ github.event.issue.number }}. Your only job is to decide whether to assign the Copilot coding agent or do nothing.

## Required step

Fetch the current labels on issue #${{ github.event.issue.number }} using the `issues` toolset.

## Decision rules

These rules are absolute.

1. **If** the issue has **both** the `experiment-pipeline` label **and** the `new-service` label: call `assign_to_agent` to assign the Copilot coding agent. Do nothing else.
2. **Otherwise** (either label missing): call `noop`. Do nothing else.

Do not classify the issue. Do not add or remove labels. Do not post comments. Do not read or summarise the issue body or title. The only data you need is the list of labels currently on the issue.

## Why these rules exist

- The upstream Pipeline Issue Triage workflow classifies issues and applies the `new-service` label on the `opened` event.
- A maintainer opts an already-triaged issue into the automated pipeline by adding `experiment-pipeline`.
- Because this workflow fires on every `labeled` event (including the `new-service` label applied by triage), we gate on the presence of both labels rather than on which specific label fired the run. The `noop` path handles all non-matching cases silently.
