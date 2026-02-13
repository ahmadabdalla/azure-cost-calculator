# Azure Cost Calculator Skill

AI agent skill for real-time Azure cost estimation using the Azure Retail Prices API.

## Skill directory

The installable skill lives at `skills/azure-cost-calculator/`.

## Key files

- `skills/azure-cost-calculator/SKILL.md` -- entry point; defines the agent workflow
- `skills/azure-cost-calculator/references/` -- service reference files and shared context
- `skills/azure-cost-calculator/scripts/` -- PowerShell helpers (Get-AzurePricing, Explore-AzurePricing)
- `tests/` -- Validation scripts (Validate-ServiceReference)

## For contributors

- Service reference files live in `skills/azure-cost-calculator/references/services/`.
- Follow the template at `skills/azure-cost-calculator/references/services/TEMPLATE.md`.
- Each service file must stay under 100 lines.
- Run the validation script before submitting:
  ```
  pwsh tests/Validate-ServiceReference.ps1
  ```
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contributor guide.
