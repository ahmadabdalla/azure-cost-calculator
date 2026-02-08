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

## Reference Index (load on demand)

| Condition                                                | Read                                                                                    |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Always (entry point)                                     | [references/shared.md](references/shared.md) — constants, category index, alias lookup  |
| Query returned 0 results or wrong data                   | [references/pitfalls.md](references/pitfalls.md) — troubleshooting and traps            |
| User asks about Reserved Instances or savings plans      | [references/reserved-instances.md](references/reserved-instances.md)                    |
| Non-USD currency or non-eastus region                    | [references/regions-and-currencies.md](references/regions-and-currencies.md)            |
| Category Index + file search both failed                 | [references/service-routing.md](references/service-routing.md) — full 140+ service map  |
| First time running scripts or unfamiliar with parameters | [references/workflow.md](references/workflow.md) — script parameters and output formats |

## Critical Rules

1. **Never guess prices** — always run the script against the live API
2. **Filter values are case-sensitive** — use exact values from the service reference file
3. **Infer currency and region from user context** — if unspecified, ask the user or default to USD and eastus. The API supports all major currencies (USD, AUD, EUR, GBP, JPY, CAD, INR, etc.) via the `-Currency` parameter.
4. **State assumptions** — always declare: region, OS, commitment type, instance count
5. **Ask before assuming** — if a required parameter is ambiguous or missing (tier, SKU, quantity, currency, node count, traffic volume), stop and ask the user before proceeding. Do not silently pick a default. The only exceptions are constants defined in service reference files (e.g., mandatory default CU counts) — those are pre-approved defaults.
6. **Default output format is Json** — do not use Summary (invisible to agents)
7. **Lazy-load service references** — only read files from `references/services/` that are directly required by the user's query. Never bulk-read all service files. Use the file-search workflow (Step 2) to locate the specific file(s). If the user asks about App Service and SQL Database, search for each and read only those files — not the other 20+.

## Universal Traps

These 4 traps apply to EVERY query — do not skip them:

1. **`serviceName` and all filter values are case-sensitive** — always use exact values from the service reference file. Never guess from portal/docs names.
2. **Unfiltered queries return mixed SKU variants** — without `productName`/`skuName` filters, results mix Spot, Low Priority, and OS variants. Always filter to the specific variant needed.
3. **Multi-meter resources need separate queries** — many resources have multiple cost components (compute + storage, fixed + variable). Run one query per meter with `-MeterName`.
4. **`Write-Host` output is invisible to agents** — always use `-OutputFormat Json` (the default). Never use `Summary` format.

## Batch Estimation Mode

When estimating **3 or more services**, use these rules to reduce token consumption:

1. **Partial reads** — read only lines 1–45 of each service file. These lines contain: YAML front matter, primary cost description, trap warning, and the first (most common) query pattern.
2. **Full read triggers** — only read the full service file if:
   - The partial read does not contain a usable query pattern
   - The user requests a non-default tier, SKU, or configuration
   - The service has complex multi-meter billing that needs the full meter table
   - The query returns 0 or unexpected results
3. **Parallel queries** — run `Get-AzurePricing.ps1` calls in parallel where possible. Independent services have no query dependencies.
4. **Skip redundant references** — do not re-read shared.md or pitfalls.md between services. Read them once at the start.

## Architecture Estimation Mode

When estimating a **complete architecture** (5+ services), follow this workflow to minimize round-trips:

1. **Decompose** — parse the architecture description and list all billable Azure services identified
2. **Map** — resolve each service to its reference file using file search (Step 2 from Workflow)
3. **Propose defaults** — present ALL services with proposed defaults (tier, SKU, region, quantity) in a single table for bulk confirmation. Use these safe defaults unless the user specifies otherwise:
   - Tier: General Purpose / Standard
   - Redundancy: LRS (storage), Zone-redundant where available
   - Region: user's stated region or eastus
   - Commitment: Pay-as-you-go (no RI)
4. **Confirm once** — let the user review and override any defaults in one response, not 25 separate questions. Rule #5 ("ask before assuming") is satisfied by this bulk confirmation step.
5. **Batch queries** — run all `Get-AzurePricing.ps1` calls using batch estimation mode (partial reads, parallel queries)
6. **Consolidated output** — present results as a single cost table with: Service | SKU/Tier | Unit Price | Qty/Multiplier | Monthly Cost, plus a total row and an assumptions footnote

> **Note**: Cross-service dependencies to watch for: AKS nodes are VMs (budget both AKS uptime SLA + VM node costs), Container Apps may need ACR, App Service apps share an App Service Plan, VNet peering has bilateral costs.
