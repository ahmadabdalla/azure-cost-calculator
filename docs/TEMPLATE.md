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

# ── API Identity (optional) ──────────────────────────────
# apiServiceName: { only when API serviceName ≠ display serviceName,
#   e.g., VMware Solution → "Specialized Compute", Static Web Apps → "Azure App Service" }

# ── Pricing Profile ──────────────────────────────────────
primaryCost:
  {
    required — one-line billing summary (max 120 chars),
    e.g.,
    "Compute hours × 730 × instanceCount",
    "Per-execution + GB-seconds with free grant deduction",
  }
# hasMeters: false                  # optional — default: true; set false for API-unavailable services
# pricingRegion: global             # optional — default: regional; enum: regional | global | empty-region | api-unavailable
# hasKnownRates: true               # optional — default: false; set true when file has Known Rates table

# ── Service Capabilities (optional) ──────────────────────
# hasFreeGrant: true                # optional — default: false; set true for free tier / included units
# privateEndpoint: true             # optional — default: false; set true for PE support
---

# {Service Display Name}

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
      content. This budget covers YAML, title, traps, query patterns,
      tables, formulas, and notes. Optimize for density — every line costs tokens
      at runtime.

  0c. SECTION ORDER (enforced by validation): Sections must appear in this order:
        YAML front matter → Title (H1) → Trap(s) → Query Pattern →
        Key Fields → Meter Names → Cost Formula → Notes →
        Optional sections
      Required sections (Query Pattern, Cost Formula, Notes) must always be
      present. Order-enforced sections (Query Pattern, Key Fields, Meter Names,
      Cost Formula, Notes) must maintain their relative order when present.
      All optional sections must appear after Notes.

  1. TITLE: Use the official Azure service name as shown in the portal.

  1b. METADATA (required): Add YAML front matter with `---` delimiters BEFORE the title:
     - serviceName: Display/logical service name matching the routing map entry. For most services this equals the API serviceName; for split-product services, use `apiServiceName` for the API value.
     - category: Category folder (compute, databases, etc.)
     - aliases: Inline [...] format — common names, abbreviations, synonyms
     - billingNeeds (optional): Routing map display names of other services this depends on (e.g., Virtual Machines). Omit if self-contained.
     - billingConsiderations (optional): Reserved Instances, Spot Pricing, Azure Hybrid Benefit,
       M365 / Windows per-user licensing. Omit if standard PAYG only.
     - apiServiceName (optional): Only when API serviceName differs from display name. Omit if identical.
     - primaryCost (required): One-line billing summary, max 120 chars.
     - hasMeters (optional, default: true): Set false for API-unavailable services. Omit when true.
     - pricingRegion (optional, default: regional): regional | global | empty-region | api-unavailable. Omit when regional.
     - hasKnownRates (optional, default: false): Set true when file has Known Rates table. Omit when false.
     - hasFreeGrant (optional, default: false): Set true for free tier / included units. Omit when false.
     - privateEndpoint (optional, default: false): Set true for PE support. Omit when false.
     Elision rule: omit any field whose value matches its default.

  2. TRAPS (optional but highly encouraged): Document pricing API gotchas.
     Include: what goes wrong, how to avoid it, agent instruction if needed.
     Use descriptive names: **Trap (RI MonthlyCost)**: ...

  3. QUERY PATTERN: Declarative Key: Value blocks (no code fences).
     For Global-only pricing, provide direct API calls in declarative format.

  3b. SCALING: At least one query must demonstrate InstanceCount: N or Quantity: N.

  4. KEY FIELDS: Table with Parameter, How to determine, Example values.

  5. METER NAMES: Exact meter names as a table. Case-sensitivity is assumed.

  6. COST FORMULA: Mathematical formula(s) for monthly cost.
     Include free tier/grant deductions where applicable.

  7. NOTES: Free tiers, SKU guidance, common mistakes, pricing links, etc.
     PRIVATE ENDPOINT SUPPORT: Set `privateEndpoint: true` in YAML when supported.
     Only add a Notes bullet for tier restrictions/caveats or multiple PE sub-resources.
     If no PE support, omit both the YAML field and the note.

  8. OPTIONAL SECTIONS (add as needed, after Notes):
     - Reserved Instance Pricing (with RI-specific traps)
     - Manual Calculation Example (for sub-cent or complex pricing)
     - Known Rates table (for services where API returns $0.00)
     - Common SKUs table (sizes, vCPUs, RAM)
     - Product Names table (lookup reference)
     - SKU Selection Guide
     - Sub-product queries (for services with multiple billing components)

  STYLE RULES:
  - No "verified" dates anywhere. Content is current as of last commit.
  - No "(case-sensitive)" annotations on headers — universal rule in shared.md.
  - Clean headers: ## Meter Names, ## Product Names, etc.
  - Blockquote formats: > **Trap**: / > **Trap ({name})**: / > **Agent instruction**: /
    > **Warning**: / > **Note**: — no emoji prefixes

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
  - Always include ServiceName at minimum; repeat it in every query block
  - Add ProductName, SkuName, MeterName as needed for precise results
  - Show the most filtered query first; add variants for tiers, OS, SKUs
  - For Global-only pricing, use direct API calls in declarative format:
    API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq '{serviceName}' and ...
    Fields: meterName, unitPrice, unitOfMeasure
  - Use PriceType: Reservation for RI queries
  - Use Quantity: N for per-unit meters, InstanceCount: N for multiple resources
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
  - Use 730 hours/month for hourly, 30 days/month for daily billing
  - Show free tier deductions with max(0, ...) where applicable
  - For multi-component services, show each component then total
  - For sub-cent pricing ($0.00 in script), provide known rates + manual calc

  Common patterns:
    Hourly:        Monthly = retailPrice × 730 × instanceCount
    Per-GB:        Monthly = retailPrice × sizeInGB
    Per-operation:  Monthly = (operations / unitSize) × retailPrice
    Composite:     Monthly = Compute + Storage + Operations
    Free grant:    Billable = max(0, total - freeGrant)

  Variables: retailPrice (single), compute_retailPrice / storage_retailPrice (multi)
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
  OPTIONAL SECTIONS — add any of the below as needed. Delete sections that don't apply.
-->

<!-- === RESERVED INSTANCE PRICING === -->
<!--
## Reserved Instance Pricing
ServiceName: {serviceName}
MeterName: {meterName}
PriceType: Reservation
> **Trap (RI MonthlyCost)**: The script's `MonthlyCost` is wrong for Reservation items — it multiplies
> the total term price by 730 hours. Always calculate: `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year).
-->
<!-- === MANUAL CALCULATION EXAMPLE === -->
<!--
## Manual Calculation Example
For {scenario, e.g., "2M executions/month at 512 MB, 1s duration"}:
```
{Step-by-step calculation}
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
> For non-USD currencies, use the method in [regions-and-currencies.md](../../regions-and-currencies.md).
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
