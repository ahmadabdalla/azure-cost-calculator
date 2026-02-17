````markdown
---
serviceName: { exact serviceName from API }
category:
  {
    category folder name — must match a category in shared.md Service Routing Map,
    e.g.,
    compute,
    containers,
    databases,
    networking,
    storage,
    security,
    monitoring,
    management,
    integration,
    analytics,
    ai-ml,
    iot,
    developer-tools,
    identity,
    migration,
    web,
    communication,
    specialist,
  }
aliases:
  [{ from routing map — use exactly the aliases listed, do not add extras }]
billingNeeds:
  [
    {
      optional — services billed under a different serviceName,
      e.g.,
      Virtual Machines,
      Managed Disks,
    },
  ]
billingConsiderations:
  [
    {
      optional — pricing factors to ask user about: Reserved Instances,
      Spot Pricing,
      Azure Hybrid Benefit,
      M365 / Windows per-user licensing,
    },
  ]
---

# {Service Display Name}

**Primary cost**: {One-line summary of the main billing dimensions, e.g., "Compute hours × 730" or "Operations per-10K + storage per-GB/month"}

<!--
  INSTRUCTIONS FOR AUTHORS:

  0. 45-LINE RULE: The first Query Pattern example MUST be the most common/default
     configuration and MUST appear within the first 45 lines of the file. This enables
     batch estimation mode to read only lines 1–45 for multi-service estimates.
     Ensure the first usable default Query Pattern (declarative Key: Value block,
     not including comments or purely instructional content) appears within lines
     1–45. Do not rely on exact line ranges for YAML front matter, titles, or
     trap warnings — their length may vary.

  0b. 100-LINE LIMIT: The total file length must not exceed 100 lines of markdown
      content. This budget covers YAML, title, primary cost, traps, query patterns,
      tables, formulas, and notes. Optimize for density — every line costs tokens
      at runtime.

  0c. SECTION ORDER (enforced by validation): Sections must appear in this order:
        YAML front matter → Title (H1) → Primary cost → Trap(s) →
        Query Pattern → Key Fields → Meter Names → Cost Formula →
        Notes → Optional sections
      Required sections (Query Pattern, Key Fields, Meter Names, Cost Formula,
      Notes) must maintain their relative order even if some are absent.
      All optional sections must appear after Notes.

  1. TITLE: Use the official Azure service name as shown in the portal.

  1b. METADATA (required): Add YAML front matter with `---` delimiters BEFORE the title:
     - serviceName: The exact case-sensitive value from the Retail Prices API
     - category: The category folder this file lives in (compute, databases, etc.)
     - aliases: Common names, abbreviations, and synonyms users might search for
       Always use inline [...] format for aliases — never multi-line YAML sequences.
     - billingNeeds (optional): Other Azure services billed under a different
       serviceName when deploying this service. Values are service display names
       (e.g., Virtual Machines, Managed Disks). Omit if the service is self-contained.
     - billingConsiderations (optional): Pricing factors the agent should ask the
       user about before calculating. Use only these values:
       Reserved Instances, Spot Pricing, Azure Hybrid Benefit, M365 / Windows per-user licensing.
       Omit entirely if none apply — absence means standard PAYG pricing only.

  2. PRIMARY COST: A concise summary of the main billing dimensions.
     Examples:
       - "Fixed hourly rate for the plan SKU × 730"
       - "vCore hourly rate + storage per-GB/month"
       - "Execution count + execution time (GB-seconds)"
       - "Per-endpoint hours + data processed per-GB"

  3. TRAPS (optional but highly encouraged): Document any pricing API
     gotchas discovered during verification. Each trap should include:
       - What goes wrong (e.g., inflated totals, wrong meters returned)
       - How to avoid it (specific filter values)
       - Agent instruction if the AI needs special handling
     Use a descriptive name in parentheses for traps that need identification,
     e.g., **Trap (RI MonthlyCost)**: ...

  4. QUERY PATTERN: Provide declarative Key: Value parameter blocks (no code fences).
     If the service requires direct API calls (e.g., Global-only pricing),
     provide API URL and Fields in declarative format instead and explain why.

  4b. SCALING: At least one query pattern must demonstrate scaling with
      InstanceCount: N (for multi-unit resources) or Quantity: N (for
      usage-based meters), with a brief comment explaining the parameter.

  5. KEY FIELDS: Document the exact API field values (case-sensitive).
     Organize as a table with Parameter, How to determine, Example values.

  6. METER NAMES: Document exact meter names as a table. All meter/SKU/
     product names are CASE-SENSITIVE — this is assumed throughout and does
     not need to be stated per-section.

  7. COST FORMULA: Provide the mathematical formula(s) for monthly cost.
     Include free tier/grant deductions where applicable.

  8. NOTES: Additional context — free tiers, SKU guidance, common
     mistakes, links to pricing pages, private endpoint support, etc.
     PRIVATE ENDPOINT SUPPORT: Every service reference must document whether
     the service supports private endpoints. Use this pattern in Notes:
       - Supports private endpoints — see `networking/private-link.md` for PE and DNS zone pricing
     If PE requires a specific tier, add it in parentheses before the dash:
       - Supports private endpoints (Premium required) — see `networking/private-link.md` ...
     If the service has multiple PE sub-resources, list them as never-assume:
       - Supports private endpoints — see ... PE sub-resources (never-assume): `blob`, `file`, ...
     If the service does NOT support PE, omit the line (no negative statement needed).

  9. OPTIONAL SECTIONS (add as needed, after Notes):
     - Reserved Instance Pricing (with RI-specific traps)
     - Manual Calculation Example (for sub-cent or complex pricing)
     - Known Rates table (for services where API returns $0.00)
     - Common SKUs table (sizes, vCPUs, RAM)
     - Product Names table (lookup reference)
     - SKU Selection Guide
     - Sub-product queries (for services with multiple billing components)

  STYLE RULES:
  - Do NOT include "verified" dates anywhere (section headers, traps, notes,
    tables). All content is assumed current as of the last commit.
  - Do NOT annotate section headers with "(case-sensitive)" or similar —
    case-sensitivity of API values is a universal rule stated in shared.md.
  - Keep section headers clean: ## Meter Names, ## Product Names, etc.
  - Trap format: > **Trap**: ... or > **Trap ({descriptive name})**: ...
  - Agent instruction format: > **Agent instruction**: ...
  - Warning format: > **Warning**: ... (for API-unavailable or USD-only notices)
  - Note format: > **Note**: ... (for informational blockquotes)
  - Do not use emoji prefixes (⚠) in blockquotes

  DELETE THIS COMMENT BLOCK BEFORE PUBLISHING.
-->

> **Trap**: {Description of a common pricing API gotcha — e.g., unfiltered queries returning too many meters, summary totals being inflated, wrong meter names, sub-cent rounding to $0.00, etc. Explain what goes wrong and how to avoid it.}
>
> **Agent instruction**: {Optional — specific guidance for the AI agent, e.g., "Do NOT report $0.00 to the user", "Always ignore the script's MonthlyCost for Reservation items", etc.}

> **Warning**: {For API-unavailable, Global-only, or USD-only pricing notices — e.g., "This service has no regional pricing — use direct API query with USD only."}

> **Note**: {For informational context that is not a trap or warning — e.g., "The Azure Portal calls this service 'X' but the API uses 'Y'."}

## Query Pattern

### {Description of what this query returns}

ServiceName: {serviceName}
SkuName: {skuName}
ProductName: {productName}
MeterName: {meterName}

<!--
  QUERY PATTERN GUIDANCE:
  - Use declarative Key: Value pairs — no code fences, no script names
  - Always include ServiceName at minimum
  - Repeat ServiceName: in every query block — do not omit it with an
    "All patterns below use..." preamble. Batch mode parses blocks individually.
  - Add ProductName, SkuName, MeterName as needed to get precise results
  - Show the recommended (most filtered) query first
  - Add variants for different tiers, OS types, or SKUs
  - If the script doesn't work for this service (e.g., Global-only pricing),
    provide direct API calls in declarative format:

    API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq '{serviceName}' and ...
    Fields: meterName, unitPrice, unitOfMeasure

  - Use PriceType: Reservation for reserved instance queries
  - Use Quantity: N for meters priced per-unit (e.g., per 100 RU/s)
  - Use InstanceCount: N for multiple identical resources

  Available declarative keys (translated to runtime flags automatically):
    ServiceName, ProductName, SkuName, MeterName, PriceType,
    Quantity, InstanceCount, Region, ArmSkuName, Currency,
    HoursPerMonth, OutputFormat
-->

## Key Fields

| Parameter     | How to determine                       | Example values                 |
| ------------- | -------------------------------------- | ------------------------------ |
| `serviceName` | {How to find the correct service name} | `{exact serviceName value}`    |
| `productName` | {How to determine the product name}    | `{exact productName value(s)}` |
| `skuName`     | {What determines the SKU selection}    | `{exact skuName value(s)}`     |
| `meterName`   | {What the meter represents}            | `{exact meterName value(s)}`   |

## Meter Names

<!--
  Use one of these table formats depending on complexity:

  SIMPLE (few meters):
  | Meter | unitOfMeasure | Notes |

  DETAILED (many meters or multiple tiers):
  | Meter | skuName | productName | unitOfMeasure | Notes |
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

  Variable naming convention:
    Single component:   retailPrice
    Multi-component:    compute_retailPrice, storage_retailPrice, backup_retailPrice
-->

## Notes

- {Free tier details, if any}
- {Default configuration assumptions}
- {Common mistakes to avoid}
- {Capacity planning: what 1 scalable unit provides in throughput/requests/connections}
- {Tier limitations: features or meters that differ between tiers}
- {Links to Azure pricing page if useful}
- {Relationship to other services, e.g., "Node VMs are priced as Virtual Machines"}
- {Private endpoint support — state whether the service supports PE and reference `networking/private-link.md` for PE and DNS zone pricing. Include tier requirements if PE is only available on certain tiers. If the service has multiple PE sub-resources, list them as never-assume parameters.}

<!--
  OPTIONAL SECTIONS — add any of the below as needed for the service.
  Delete sections that don't apply.
-->

<!-- === RESERVED INSTANCE PRICING === -->
<!--
## Reserved Instance Pricing

ServiceName: {serviceName}
MeterName: {meterName}
PriceType: Reservation

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
## Known Rates

| Meter | Unit | Published Rate (USD) | Free Grant |
| ----- | ---- | -------------------- | ---------- |
| `{meter}` | {unit} | ${rate} | {grant or N/A} |

> These rates are from the [Azure pricing page]({url}). The API returns them
> but at precision below what the script rounds to — the script shows `$0.00`.
> For non-USD currencies, use the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md).
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
## Product Names

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
