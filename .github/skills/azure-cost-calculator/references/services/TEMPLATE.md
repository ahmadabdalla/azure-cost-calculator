````markdown
# {Service Display Name}

**Primary cost**: {One-line summary of the main billing dimensions, e.g., "Compute hours × 730" or "Operations per-10K + storage per-GB/month"}

<!--
  INSTRUCTIONS FOR AUTHORS:

  1. TITLE: Use the official Azure service name as shown in the portal.

  2. PRIMARY COST: A concise summary of the main billing dimensions.
     Examples:
       - "Fixed hourly rate for the plan SKU × 730"
       - "vCore hourly rate + storage per-GB/month"
       - "Execution count + execution time (GB-seconds)"
       - "Per-endpoint hours + data processed per-GB"

  3. TRAPS (optional but highly encouraged): Document any pricing API
     gotchas discovered during verification. Each trap should include:
       - Verified date in parentheses
       - What goes wrong (e.g., inflated totals, wrong meters returned)
       - How to avoid it (specific filter values)
       - Agent instruction if the AI needs special handling

  4. QUERY PATTERN: Provide copy-paste-ready Get-AzurePricing.ps1 commands.
     If the service requires direct API calls (e.g., Global-only pricing),
     provide raw Invoke-RestMethod examples instead and explain why.

  5. KEY FIELDS / METER NAMES: Document the exact API field values
     (case-sensitive) with verification dates. Organize as tables.

  6. COST FORMULA: Provide the mathematical formula(s) for monthly cost.
     Include free tier/grant deductions where applicable.

  7. NOTES: Additional context — free tiers, SKU guidance, common
     mistakes, links to pricing pages, etc.

  8. OPTIONAL SECTIONS (add as needed):
     - Reserved Instance Pricing (with RI-specific traps)
     - Manual Calculation Example (for sub-cent or complex pricing)
     - Known Rates table (for services where API returns $0.00)
     - Common SKUs table (sizes, vCPUs, RAM)
     - Product Names table (case-sensitive lookup reference)
     - Tier/SKU Selection Guide
     - Sub-product queries (for services with multiple billing components)

  DELETE THIS COMMENT BLOCK BEFORE PUBLISHING.
-->

> **Trap (verified {YYYY-MM-DD})**: {Description of a common pricing API gotcha — e.g., unfiltered queries returning too many meters, summary totals being inflated, wrong meter names, sub-cent rounding to $0.00, etc. Explain what goes wrong and how to avoid it.}
>
> **Agent instruction**: {Optional — specific guidance for the AI agent, e.g., "Do NOT report $0.00 to the user", "Always ignore the script's MonthlyCost for Reservation items", etc.}

## Query Pattern

```powershell
# {Description of what this query returns}
.\Get-AzurePricing.ps1 `
    -ServiceName '{serviceName}' `
    -SkuName '{skuName}' `
    -ProductName '{productName}' `
    -MeterName '{meterName}'
```

<!--
  QUERY PATTERN GUIDANCE:
  - Always include -ServiceName at minimum
  - Add -ProductName, -SkuName, -MeterName as needed to get precise results
  - Show the recommended (most filtered) query first
  - Add variants for different tiers, OS types, or SKUs
  - If the script doesn't work for this service (e.g., Global-only pricing),
    provide direct API calls using Invoke-RestMethod instead:

    $uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq '{serviceName}' and ..."
    (Invoke-RestMethod -Uri $uri).Items | Select-Object meterName, unitPrice, unitOfMeasure

  - Use -PriceType Reservation for reserved instance queries
  - Use -Quantity N for meters priced per-unit (e.g., per 100 RU/s)
  - Use -InstanceCount N for multiple identical resources
-->

## Key Fields

| Parameter     | How to determine                       | Example values                 |
| ------------- | -------------------------------------- | ------------------------------ |
| `serviceName` | {How to find the correct service name} | `{exact serviceName value}`    |
| `productName` | {How to determine the product name}    | `{exact productName value(s)}` |
| `skuName`     | {What determines the SKU selection}    | `{exact skuName value(s)}`     |
| `meterName`   | {What the meter represents}            | `{exact meterName value(s)}`   |

## Meter Names (verified {YYYY-MM-DD})

<!--
  Use one of these table formats depending on complexity:

  SIMPLE (few meters):
  | Meter | unitOfMeasure | Notes |

  DETAILED (many meters or multiple tiers):
  | Meter | skuName | productName | unitOfMeasure | Notes |

  All meter/SKU/product names are CASE-SENSITIVE — always verify against the API.
-->

| Meter           | unitOfMeasure | Notes                      |
| --------------- | ------------- | -------------------------- |
| `{meterName 1}` | `{unit}`      | {What this meter measures} |
| `{meterName 2}` | `{unit}`      | {What this meter measures} |

## Cost Formula

```
Monthly = {formula using retailPrice, hours, quantities, etc.}
```

<!--
  COST FORMULA GUIDANCE:
  - Use 730 hours/month for hourly-billed services
  - Show free tier/grant deductions with max(0, ...) where applicable
  - For tiered pricing, show the tier calculation
  - For multi-component services, show each component then the total
  - For sub-cent pricing where the script shows $0.00, provide the
    known published rates and a manual calculation example

  Common patterns:
    Hourly:        Monthly = retailPrice × 730 × instanceCount
    Per-GB:        Monthly = retailPrice × sizeInGB
    Per-operation:  Monthly = (operations / unitSize) × retailPrice
    Tiered:        Monthly = Σ(retailPrice_tier × units_in_tier)
    Composite:     Monthly = Compute + Storage + Operations
    Free grant:    Billable = max(0, total - freeGrant)
-->

## Notes

- {Free tier details, if any}
- {Default configuration assumptions}
- {Common mistakes to avoid}
- {Links to Azure pricing page if useful}
- {Relationship to other services, e.g., "Node VMs are priced as Virtual Machines"}

<!--
  OPTIONAL SECTIONS — add any of the below as needed for the service.
  Delete sections that don't apply.
-->

<!-- === RESERVED INSTANCE PRICING === -->
<!--
## Reserved Instance Pricing

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName '{serviceName}' `
    -MeterName '{meterName}' `
    -PriceType Reservation
```

> **Trap (RI MonthlyCost)**: The script's `MonthlyCost` is wildly wrong for
> Reservation items — it multiplies the total term price by 730 hours.
> Always manually calculate: `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year).
> Both terms are returned in a single query — select the desired term from results.
-->

<!-- === MANUAL CALCULATION EXAMPLE === -->
<!--
## Manual Calculation Example

For {describe scenario, e.g., "2M executions/month at 512 MB memory, 1s average duration"}:

```
{Step-by-step calculation with actual numbers}
Total = ${result} USD/month
```
-->

<!-- === KNOWN RATES (for sub-cent pricing) === -->
<!--
## Known Rates (verified {YYYY-MM-DD})

| Meter | Unit | Published Rate (USD) | Free Grant |
| ----- | ---- | -------------------- | ---------- |
| `{meter}` | {unit} | ${rate} | {grant or N/A} |

> These rates are from the [Azure pricing page]({url}). The API returns them
> but at precision below what the script rounds to — the script shows `$0.00`.
> For non-USD currencies, use the currency derivation method in [shared.md](../shared.md).
-->

<!-- === COMMON SKUS TABLE === -->
<!--
## Common SKUs

| SKU | vCPUs | RAM (GB) | Tier/Notes |
| --- | ----- | -------- | ---------- |
| `{sku}` | {n} | {n} | {tier or use case} |
-->

<!-- === PRODUCT NAMES TABLE === -->
<!--
## Product Names (case-sensitive)

| Configuration | productName |
| ------------- | ----------- |
| {config description} | `{exact productName}` |
-->

<!-- === TIER / SKU SELECTION GUIDE === -->
<!--
## SKU Selection Guide

| Workload Type | SKU | Pricing Model | Notes |
| ------------- | --- | ------------- | ----- |
| {workload description} | `{sku}` | {model} | {notes} |
-->
````
