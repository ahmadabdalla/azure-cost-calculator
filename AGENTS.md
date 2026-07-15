# Azure Cost Calculator Skill

AI agent plugin for real-time Azure cost estimation using the Azure Retail Prices API.

## Repository layout

| Path                                       | Purpose                                                                                                                                   |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `skills/azure-cost-calculator/`            | Installable skill (entry point: `SKILL.md`)                                                                                               |
| `skills/azure-cost-calculator/scripts/`    | Pricing scripts: PowerShell (`Get-AzurePricing.ps1`, `Explore-AzurePricing.ps1`) and Bash equivalents, plus shared libs in `scripts/lib/` |
| `skills/azure-cost-calculator/references/` | Service reference files, shared context, and example architectures (`references/examples/`)                                               |
| `agents/`                                  | Plugin agents (e.g. `cost-analyst.agent.md`)                                                                                              |
| `commands/`                                | Plugin commands (e.g. `estimate-cost.md`)                                                                                                 |
| `.claude-plugin/plugin.json`               | Plugin manifest (canonical source of version)                                                                                             |
| `tests/`                                   | Validation scripts and unit tests (Pester 5 + bats-core)                                                                                  |
| `tests/evals/`                             | Waza evaluation suites and task definitions for behavior quality checks                                                                   |
| `.waza.yaml`                               | Project-level Waza configuration (paths, defaults, and runtime settings)                                                                  |
| `docs/`                                    | Templates (`TEMPLATE.md`), plugin docs, and operational guides (`docs/ops/`)                                                              |

## Git conventions

- Feature and contributor pull requests target the `dev` branch (`--base dev` on `gh pr create`).

## CI

PRs automatically run:

- **validate-service-references**: Syntax, routing, alias uniqueness checks on service reference files.
- **unit-tests**: PowerShell (Pester) and Bash (bats) tests when scripts or tests change.
- **eval**: Waza schema validation, mock pipeline check, and targeted critical-path evals for relevant skill changes.

Releases are handled by `create-release.yml` when a PR with a `release: ` prefix merges to `main`. Version is read from `.claude-plugin/plugin.json`.

## For contributors

- Service reference files live in `skills/azure-cost-calculator/references/services/`.
- Follow the template at `docs/TEMPLATE.md`.
- Run the validation script before submitting:
  ```
  pwsh tests/Validate-ServiceReference.ps1 -Path <file> -CheckAliasUniqueness -CheckRoutingFileSync
  ```
- Run unit tests when changing core scripts:
  ```
  pwsh tests/unit/Run-PesterTests.ps1
  bash tests/unit/run-bats-tests.sh
  ```
- Run eval checks when changing skill behavior, service references, eval tasks, or eval workflow:
  ```
  waza check
  waza run --tags "service:<service-name>" --output results/results.json
  ```
- For real-model eval runs, set `COPILOT_GITHUB_TOKEN` (fine-grained PAT with "Copilot Requests" permission).
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contributor guide.

## For maintainers

- Operational documentation lives in `docs/ops/`.
- When implementing or changing a repo feature (workflows, automation, infrastructure), create or update the corresponding ops doc.
- Each ops doc should cover: what the feature does, prerequisites, how to make changes, troubleshooting, and external references.
- Tests must be created or updated in the `tests/` folder, not inside `skills/`.
- The `skills/` folder is for end-users installing the skill; it should only contain artifacts they use. Do not place maintainer-only files (tests, docs, tooling) there.
