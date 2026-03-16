---
name: azure-cost-calculator
description: Helps estimate and calculate Azure resource costs. Use this skill when users ask about Azure pricing, cost estimation, resource sizing costs, comparing pricing tiers, budgeting for Azure deployments, or understanding Azure billing. Triggers include questions like "how much will this cost in Azure", "estimate Azure costs", "compare Azure pricing", "budget for Azure resources".
license: MIT
argument-hint: "<azure-service-name>"
compatibility: Requires curl + jq (macOS/Linux) or PowerShell 7+ (pwsh) or Windows PowerShell 5.1 (powershell.exe on Windows), and internet access to prices.azure.com. No Azure subscription needed.
metadata:
  author: ahmadabdalla
  version: "1.3.1"
---

# Azure Cost Calculator

Deterministic Azure cost estimation using the public Retail Prices API. Never guess prices — always query the live API via the scripts.

## Runtime Detection

Choose the script runtime based on what is available:

| Runtime                    | Condition                                 | Pricing script                 | Explore script                     |
| -------------------------- | ----------------------------------------- | ------------------------------ | ---------------------------------- |
| **Bash** (preferred)       | `curl` and `jq` available                 | `scripts/get-azure-pricing.sh` | `scripts/explore-azure-pricing.sh` |
| **PowerShell 7+**          | `pwsh` available                          | `scripts/Get-AzurePricing.ps1` | `scripts/Explore-AzurePricing.ps1` |
| **Windows PowerShell 5.1** | `powershell.exe` available (Windows only) | `scripts/Get-AzurePricing.ps1` | `scripts/Explore-AzurePricing.ps1` |

Both produce identical JSON output. Bash flags use `--kebab-case` equivalents of PowerShell `-PascalCase` parameters (e.g., `-ServiceName` → `--service-name`).

### Declarative Parameters

Service reference files specify query parameters as `Key: Value` pairs. Translate to Bash `--kebab-case` or PowerShell `-PascalCase` flags; quote string values with spaces. See [workflow.md](references/workflow.md) for the full parameter table, translation examples, and output formats.

## Workflow

### Phase 1 — Analysis (no API queries)

1. **Parse** — extract resource types, quantities, and sizing from user's architecture
2. **Clarify** — if any of these are true, stop and ask before continuing:
   - A resource maps to a category but not a specific service (e.g., "a database") → list 2–4 options
   - A resource has no count, no sizing/tier, or no workload scale → ask for specifics
   - A resource has no expected monthly volume — data transferred/ingested (GB), transactions, requests, messages, tokens, or users/devices → ask for estimated volume
   - A multi-model or multi-feature service (e.g., Azure OpenAI, AI Services, Defender for Cloud) has no model or feature variant specified → ask which one (cost can vary 15–30×)
   - User describes a goal without a hosting model (e.g., "a web app") → present 2–3 options with trade-offs
   - Batch all gaps into one prompt. Offer concrete choices with sensible options (e.g., "100 GB/month?", "GPT-4o or GPT-4o-mini?"). One round max — if user declines a specific parameter, use safe defaults and disclose; if no reasonable default exists, do NOT proceed — state what cannot be estimated without the missing input.
3. **Locate** each service reference using the lookup workflow in [shared.md](references/shared.md) (file search → routing map → category browse → broad search → discovery)
4. **Read** matched service files; check `billingNeeds` and follow dependency chains (e.g., AKS → VMs → Managed Disks)
5. **Classify** each parameter using the Disambiguation Protocol in [shared.md](references/shared.md):
   - **Specified** — user provided value (use verbatim)
   - **Never-assume gap** — required parameter missing (must ask)
   - **Safe-default gap** — optional parameter missing (use default, disclose)
6. **Specification Review** — present a summary:

   | Service | Specified | Missing (will ask) | Defaults (will assume) |
   | ------- | --------- | ------------------ | ---------------------- |
   - If **any never-assume parameter** is missing → ask user before proceeding
   - If only safe-default gaps remain → disclose defaults and proceed to Phase 2
   - **Single-service shortcut**: skip this table for single-service estimates where all parameters are specified

### Phase 2 — Estimation

7. **Query** — run the pricing script for each service using parameters from service files + user input + resolved defaults
8. **Calculate** — apply cost formulas from service files; multiply by quantities
9. **Verify arithmetic** — for each line item, restate the formula with actual numbers, compute, and confirm the result. If any intermediate calculation involves multiplication of two numbers > 10, compute it step-by-step (e.g., `14.5 × 640 → 14 × 640 → 10 × 640 = 6,400; 4 × 640 = 2,560; subtotal = 8,960; 0.5 × 640 = 320; total = 9,280`). Do not rely on mental math for multi-digit operations.
10. **Present** — output the estimate with:

- **Assumptions block** (see Disambiguation Protocol in shared.md) — listed before cost numbers
- **Line items**: service, unit price, quantity/hours, monthly cost
- **Grand total**: re-sum all line-item monthly costs independently; if discrepancy, use re-summed value

### Post-Estimate Iteration

After presenting the estimate, the user may request changes (switch region, add RI, resize instances, add/remove services). Re-run only the affected queries — do not restart the full workflow.

## Reference Index (load on demand)

| Condition                                                                       | Read                                                                                                                                                                                                                             |
| ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Always (entry point)                                                            | [references/shared.md](references/shared.md) — constants, category index, alias lookup                                                                                                                                           |
| Query returned 0 results or wrong data                                          | [references/pitfalls.md](references/pitfalls.md) — troubleshooting and traps                                                                                                                                                     |
| User asks about Reserved Instances or savings plans                             | [references/reserved-instances.md](references/reserved-instances.md)                                                                                                                                                             |
| Non-USD currency or non-eastus region                                           | [references/regions-and-currencies.md](references/regions-and-currencies.md)                                                                                                                                                     |
| User requests private endpoints or private access — confirm PE intent with user | [references/services/networking/private-link.md](references/services/networking/private-link.md) — PE pricing, [references/services/networking/private-dns.md](references/services/networking/private-dns.md) — DNS zone pricing |
| File search returned 0 or ambiguous results                                     | [references/service-routing.md](references/service-routing.md) - implemented services routing                                                                                                                                    |
| First time running scripts or unfamiliar with parameters                        | [references/workflow.md](references/workflow.md) — script parameters and output formats                                                                                                                                          |

## Critical Rules

1. **Never guess prices** — always run the script against the live API
2. **Infer currency and region from user context** — if unspecified, ask the user or default to USD and eastus
3. **Ask before assuming** — if a required parameter is ambiguous or missing (tier, SKU, quantity, currency, node count, monthly volume, data transfer GB, model/feature variant, users/devices), stop and ask the user. Never silently default a never-assume parameter. At the request level, clarify vague inputs (Step 2). At the parameter level, apply the Disambiguation Protocol (Step 5).
4. **Default output format is Json** — never use Summary (invisible to agents)
5. **Lazy-load service references** — only read files from `references/services/` directly required by the user's query. Use the file-search workflow (Step 2) to locate specific files.
6. **PowerShell: use `-File`, not `-Command`** — run scripts with `pwsh -File` or `powershell.exe -File`; on Linux/macOS, bash strips OData quotes from inline commands. **PS 5.1 caveat:** use `-Command` instead of `-File` when passing array parameters (e.g., `-Region 'eastus','australiaeast'`), because `-File` mode does not parse PowerShell expression syntax and collapses the array into a single string.
7. **Use exact category names** — group line items using the exact Category Index names from shared.md verbatim (e.g., "Compute", "Databases", "AI + ML"). Do not paraphrase, abbreviate, or rename them.
8. **Scope to user-specified resources** — only include resources explicitly stated in the user's architecture. Companion resources from `billingNeeds` are included automatically.

## Service File Metadata

YAML front matter fields. Optional fields use default elision — omitted means the default applies.

| Field                   | Required | Default    | Action                                                                                  |
| ----------------------- | :------: | ---------- | --------------------------------------------------------------------------------------- |
| `billingNeeds`          |    —     | omit       | Read and price listed dependency services                                               |
| `billingConsiderations` |    —     | omit       | Ask user about listed pricing factors before calculating                                |
| `primaryCost`           |    ✔     | —          | One-line billing summary for quick cost context                                         |
| `apiServiceName`        |    —     | omit       | Use instead of `serviceName` in API queries                                             |
| `hasMeters`             |    —     | `true`     | `false` → skip API, use Known Rates table                                               |
| `pricingRegion`         |    —     | `regional` | `global` → `Region: Global`; `api-unavailable` → skip API; `empty-region` → omit region |
| `hasKnownRates`         |    —     | `false`    | `true` → file contains manual pricing table                                             |
| `hasFreeGrant`          |    —     | `false`    | `true` → apply free grant deduction from Cost Formula                                   |
| `privateEndpoint`       |    —     | `false`    | `true` → aggregate PE costs via `networking/private-link.md`                            |

## Universal Traps

These apply to EVERY query:

1. **`serviceName` and all filter values are case-sensitive** — use exact values from service reference files
2. **Unfiltered queries return mixed SKU variants** — always filter with `productName`/`skuName` to the specific variant needed
3. **Multi-meter resources need separate queries** — run one query per meter with `-MeterName`

## Batch Estimation Mode

When estimating **3 or more services**, use these rules to reduce token consumption:

1. **Partial reads** — read only lines 1–45 of each service file (YAML front matter, trap, first query pattern).
2. **Front matter routing** — use YAML metadata to skip unnecessary work:
   - `hasMeters: false` / `pricingRegion: api-unavailable` → skip API; use Known Rates or `primaryCost`
   - `pricingRegion: global` → `Region: Global`; `empty-region` → omit region
   - `apiServiceName` → use instead of `serviceName` in queries
   - `hasFreeGrant: true` → apply grant deduction; `privateEndpoint: true` → add PE line item
3. **Full read triggers** — no query pattern in partial read, non-default config, 0/unexpected results, or `billingConsiderations` applies.
4. **Parallel queries** — run independent service queries in parallel.
5. **Skip redundant references** — read shared.md and pitfalls.md once at the start, not between services.
6. **Progressive distillation** — after each service query returns, emit a summary row before proceeding:
   `| Category | Service | Resource | Unit Price | Unit | Qty | Monthly Cost | Notes |`
   Multi-meter services get one row per line item. After all queries complete, assemble the final estimate from the accumulated rows. Do not re-read service files already distilled unless a full read trigger is needed. During Post-Estimate Iteration, replace the distillation row(s) for any re-queried service.
7. **Compact output** — use `OutputFormat: Compact` (or `--output-format Compact` in Bash) for batch queries. Compact returns only the 9 fields needed for cost calculation (MeterName, ProductName, SkuName, UnitPrice, UnitOfMeasure, MonthlyCost, Currency, ReservationTerm, TierMinUnits) — no query echo, no summary block. Use full `Json` format when debugging unexpected results or when a service file requires fields not in the Compact set.
