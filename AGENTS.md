# Agent Instructions

This repository contains the **azure-cost-calculator** skill for AI coding agents.

## Skill Location

The skill is located at `skills/azure-cost-calculator/`. The entry point is `skills/azure-cost-calculator/SKILL.md`.

## Key Architecture Decisions

- **Filesystem as index** — each Azure service has a dedicated `.md` reference file under `skills/azure-cost-calculator/references/services/`, organized by category
- **Lazy-load design** — only `SKILL.md` and `shared.md` load on every invocation; all other references are conditional
- **45-line rule** — the first query pattern must appear within lines 1–45 of each service file for batch estimation mode
- **Scripts abstract API complexity** — `Get-AzurePricing.ps1` handles OData filters, pagination, and monthly calculations

## Contributing

When adding or modifying service reference files:

1. Use `skills/azure-cost-calculator/references/services/TEMPLATE.md` as a starting point
2. Ensure the primary query pattern fits within the first 45 lines
3. Place files in the correct category directory
4. Run the validation workflow to verify compliance

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.
