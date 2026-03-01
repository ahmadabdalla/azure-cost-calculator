# Azure Cost Calculator Skill

AI agent skill for real-time Azure cost estimation using the Azure Retail Prices API.

## Skill directory

The installable skill lives at `skills/azure-cost-calculator/`.

## Key files

- `skills/azure-cost-calculator/SKILL.md` -- entry point; defines the agent workflow
- `skills/azure-cost-calculator/references/` -- service reference files and shared context
- `skills/azure-cost-calculator/scripts/` -- PowerShell helpers (Get-AzurePricing, Explore-AzurePricing)
- `tests/` -- Validation scripts (Validate-ServiceReference) and unit tests
- `tests/unit/` -- Unit tests for core scripts (Pester 5 + bats-core)

## Git conventions

- When creating pull requests, always target the `dev` branch (`--base dev` on `gh pr create`).

## Git conventions

- When creating pull requests, always target the `dev` branch (`--base dev` on `gh pr create`).

## For contributors

- Service reference files live in `skills/azure-cost-calculator/references/services/`.
- Follow the template at `docs/TEMPLATE.md`.
- Each service file must stay under 100 lines.
- Run the validation script before submitting:
  ```
  pwsh tests/Validate-ServiceReference.ps1 -Path <file> -CheckAliasUniqueness -CheckRoutingFileSync
  ```
- Run unit tests when changing core scripts:
  ```
  pwsh tests/unit/Run-PesterTests.ps1
  bash tests/unit/run-bats-tests.sh
  ```
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contributor guide.

## For maintainers

- Operational documentation lives in `docs/ops/`.
- When implementing or changing a repo feature (workflows, automation, infrastructure), create or update the corresponding ops doc.
- Each ops doc should cover: what the feature does, prerequisites, how to make changes, troubleshooting, and external references.
- Tests must be created or updated in the `tests/` folder, not inside `skills/`.
- The `skills/` folder is for end-users installing the skill — it should only contain artifacts they use. Do not place maintainer-only files (tests, docs, tooling) there.
