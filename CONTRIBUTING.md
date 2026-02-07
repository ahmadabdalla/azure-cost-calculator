# Contributing Service References

This guide explains how to add a new Azure service reference file to the skill. Every service reference follows a strict format to enable **batch estimation mode** — the skill's primary performance optimization.

## Why the Rules Exist

The skill reads service reference files at runtime to answer Azure pricing questions. When estimating costs for 3+ services at once, it reads only **lines 1-45** of each file. This partial read must contain:

1. YAML metadata (serviceName, category, aliases) for routing
2. A one-line cost summary
3. Any critical traps (pricing API gotchas)
4. A copy-paste-ready query pattern

If the first query pattern falls below line 45, batch mode fails and the skill must do a full file read for every service — destroying token efficiency.

All API filter values (`serviceName`, `productName`, `skuName`, `meterName`) are **case-sensitive**. A single wrong character returns zero results or wrong prices. This is why exact values from the API matter more than names from the Azure portal or documentation.

## Before You Start

> All paths below are relative to the repository root.

1. **Check the routing map** — open `.github/skills/azure-cost-calculator/references/service-routing.md` and confirm your service is listed. If it is not there, open an issue first.
2. **Check existing files** — search `.github/skills/azure-cost-calculator/references/services/` to make sure the file does not already exist.
3. **Install PowerShell** — the validation script requires PowerShell 7+.

## Step-by-Step

### 1. Discover API values

Run the exploration script to find exact filter values:

```powershell
.github/skills/azure-cost-calculator/scripts/Explore-AzurePricing.ps1 -ServiceName 'Your Service Name'
# Or search broadly:
.github/skills/azure-cost-calculator/scripts/Explore-AzurePricing.ps1 -SearchTerm 'keyword' -Top 50
```

Note the exact `serviceName`, `productName`, `skuName`, and `meterName` values returned. These are case-sensitive.

### 2. Copy the template

Copy `.github/skills/azure-cost-calculator/references/services/TEMPLATE.md` into the correct category folder:

```bash
cp .github/skills/azure-cost-calculator/references/services/TEMPLATE.md .github/skills/azure-cost-calculator/references/services/{category}/{filename}.md
```

Use the filename suggested in `.github/skills/azure-cost-calculator/references/service-routing.md`. Use lowercase with hyphens (e.g., `app-service.md`).

### 3. Fill in YAML front matter

```yaml
---
serviceName: Exact API Value
category: compute
aliases: [common name, abbreviation, synonym]
---
```

- `serviceName`: the exact case-sensitive value from the API (step 1)
- `category`: the folder name this file lives in — must match one of the 18 categories in `.github/skills/azure-cost-calculator/references/shared.md`
- `aliases`: common names users might search for — be comprehensive

### 4. Write the query pattern

Place the most common/default query first. It **must** appear within lines 1-45.

```powershell
.github/skills/azure-cost-calculator/scripts/Get-AzurePricing.ps1 `
    -ServiceName 'Exact Service Name' `
    -ProductName 'Exact Product Name' `
    -MeterName 'Exact Meter Name'
```

Run the query and verify it returns correct results before documenting it.

### 5. Document traps

If you discover pricing API gotchas during verification, document them as traps:

```markdown
> **Trap**: Description of what goes wrong and how to avoid it.
```

For named traps:

```markdown
> **Trap (RI MonthlyCost)**: Description with specific name for reference.
```

### 6. Write the cost formula

Use `retailPrice` from the API, not hardcoded prices:

```
Monthly = retailPrice x 730 x instanceCount
```

Common patterns:

- Hourly: `retailPrice x 730`
- Per-GB: `retailPrice x sizeInGB`
- Per-operation: `(operations / unitSize) x retailPrice`
- Composite: `Compute + Storage + Operations`

### 7. Validate locally

```powershell
.github/skills/azure-cost-calculator/scripts/Validate-ServiceReference.ps1 -Path .github/skills/azure-cost-calculator/references/services/{category}/{filename}.md -CheckAliasUniqueness
```

Fix any failures before submitting.

### 8. Submit your PR

Push your branch and open a pull request. CI runs the same validation automatically.

## Common Mistakes

**Wrong `serviceName` casing**

```diff
- serviceName: virtual machines
+ serviceName: Virtual Machines
```

The API value is case-sensitive. Use `.github/skills/azure-cost-calculator/scripts/Explore-AzurePricing.ps1` to find the exact value.

**Missing `productName` filter**

```diff
  .\Get-AzurePricing.ps1 `
      -ServiceName 'Key Vault' `
-     -SkuName 'Standard'
+     -SkuName 'Standard' `
+     -ProductName 'Key Vault'
```

Without `-ProductName`, the query may return meters from related but different services (e.g., Dedicated HSM mixed with Key Vault).

**Query pattern below line 45**

Keep the YAML front matter, title, primary cost, and trap concise. The first ` ```powershell ` block must start within the first 45 lines.

**Hardcoded prices**

```diff
- Monthly = $0.10 x hours
+ Monthly = retailPrice x 730
```

Prices change. Always reference `retailPrice` from the API query results.

## Complexity Tiers

Set expectations for how long a service file takes to write:

| Tier    | Examples                    | Time     | Characteristics                                    |
| ------- | --------------------------- | -------- | -------------------------------------------------- |
| Simple  | Key Vault, DDoS Protection  | ~30 min  | 1 meter, 1 SKU, straightforward formula            |
| Medium  | App Service, Redis Cache    | ~1 hour  | 2-3 meters, multiple SKUs, tier variations         |
| Complex | Cosmos DB, Virtual Machines | ~2 hours | Multi-meter, RI traps, tiered pricing, OS variants |

## Style Rules

- Do **not** include "verified" dates anywhere in the file
- Do **not** annotate headers with "(case-sensitive)" — this is a universal rule in `.github/skills/azure-cost-calculator/references/shared.md`
- Keep section headers clean: `## Meter Names`, `## Cost Formula`, etc.
- Trap format: `> **Trap**: ...` or `> **Trap ({name})**: ...`
- Use 730 hours/month for hourly billing (not 720)
- Use 30 days/month for daily billing
