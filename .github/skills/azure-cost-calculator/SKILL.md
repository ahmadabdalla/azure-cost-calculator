---
name: azure-cost-calculator
description: Helps estimate and calculate Azure resource costs. Use this skill when users ask about Azure pricing, cost estimation, resource sizing costs, comparing pricing tiers, budgeting for Azure deployments, or understanding Azure billing. Triggers include questions like "how much will this cost in Azure", "estimate Azure costs", "compare Azure pricing", "budget for Azure resources".
license: MIT
metadata:
  author: ahmadabdalla
  version: "1.0.0"
---

# Azure Cost Calculator

Deterministic Azure cost estimation using the public Retail Prices API. Never guess prices — always query the live API via the scripts.

## Workflow

1. **Identify** the resource type(s) the user wants to estimate
2. **Locate** the service reference:
   a. **File search** — search for files matching `references/services/**/*<keyword>*.md` (e.g., "Cosmos DB" → `services/**/cosmos*.md`)
   b. **Category browse** — if search returns 0 or ambiguous results, read the category index in [references/shared.md](references/shared.md) and list the matching category directory
   c. **Broad search** — list or search `references/services/**/*.md` to see all available files
   d. **Discovery** — if no file exists, use `scripts/Explore-AzurePricing.ps1` to find the service in the API
3. **Read** only the matching service file(s) for query parameters, cost formula, and the exact `serviceName`
4. **Run** `scripts/Get-AzurePricing.ps1` with the parameters from the service reference
5. **Present** the estimate with breakdown: unit price, multiplier, monthly cost, assumptions

For detailed script parameters and output formats, see [references/workflow.md](references/workflow.md).
For known traps and troubleshooting, see [references/pitfalls.md](references/pitfalls.md).
For Reserved Instance pricing traps, see [references/reserved-instances.md](references/reserved-instances.md).
For constants, category index, and pricing factors, see [references/shared.md](references/shared.md).
For region names, currency conversion, and API-unavailable services, see [references/regions-and-currencies.md](references/regions-and-currencies.md).

## Critical Rules

1. **Never guess prices** — always run the script against the live API
2. **Filter values are case-sensitive** — use exact values from the service reference file
3. **Infer currency and region from user context** — if unspecified, ask the user or default to USD and eastus. The API supports all major currencies (USD, AUD, EUR, GBP, JPY, CAD, INR, etc.) via the `-Currency` parameter.
4. **State assumptions** — always declare: region, OS, commitment type, instance count
5. **Default output format is Json** — do not use Summary (invisible to agents)
6. **Lazy-load service references** — only read files from `references/services/` that are directly required by the user's query. Never bulk-read all service files. Use the file-search workflow (Step 2) to locate the specific file(s). If the user asks about App Service and SQL Database, search for each and read only those files — not the other 20+.

## Universal Traps

These 4 traps apply to EVERY query — do not skip them:

1. **`serviceName` and all filter values are case-sensitive** — always use exact values from the service reference file. Never guess from portal/docs names.
2. **Unfiltered queries return mixed SKU variants** — without `productName`/`skuName` filters, results mix Spot, Low Priority, and OS variants. Always filter to the specific variant needed.
3. **Multi-meter resources need separate queries** — many resources have multiple cost components (compute + storage, fixed + variable). Run one query per meter with `-MeterName`.
4. **`Write-Host` output is invisible to agents** — always use `-OutputFormat Json` (the default). Never use `Summary` format.
