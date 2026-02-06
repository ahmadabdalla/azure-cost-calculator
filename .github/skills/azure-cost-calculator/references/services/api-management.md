# API Management

**Primary cost**: Unit hours based on tier

> **Trap (multiple meters per tier — verified 2026-02-06)**: Several tiers have multiple meters (e.g., `Standard v2 Unit`, `Standard v2 Secondary Unit`, `Standard v2 Self-hosted Gateway`, `Standard v2 Calls`). Always use the primary `{Tier} Unit` meter for the base deployment cost. Secondary units, self-hosted gateways, and workspace packs are additional components — do not add them to the base estimate unless the user explicitly requests them.
> **Trap (v2 tiers — verified 2026-02-06)**: Basic v2 and Standard v2 tiers also have a `Calls` meter at `$0.00` per 10K — this is for included API calls and does not need to be added to cost estimates.
> **Trap (Consumption tier — verified 2026-02-06)**: The Consumption tier uses per-call pricing (`Consumption Calls` at `$0.00/10K` in API — check live for non-zero overage rates) rather than hourly units. Do NOT multiply by 730 hours for Consumption.

## Query Pattern

```powershell
# Classic tiers (Developer, Basic, Standard, Premium)
.\Get-AzurePricing.ps1 `
    -ServiceName 'API Management' `
    -SkuName 'Standard' `
    -MeterName 'Standard Unit'

# v2 tiers (Basic v2, Standard v2, Premium v2)
.\Get-AzurePricing.ps1 `
    -ServiceName 'API Management' `
    -SkuName 'Standard v2' `
    -MeterName 'Standard v2 Unit'

# Self-hosted Gateway (Standard v2 and Premium v2 only)
.\Get-AzurePricing.ps1 `
    -ServiceName 'API Management' `
    -SkuName 'Standard v2' `
    -MeterName 'Standard v2 Self-hosted Gateway'
```

## Key Fields

| Parameter     | How to determine                          | Example values                                             |
| ------------- | ----------------------------------------- | ---------------------------------------------------------- |
| `productName` | Always `API Management`                   | `API Management`                                           |
| `skuName`     | Tier name — this selects the pricing tier | `Developer`, `Basic`, `Standard`, `Premium`, `Standard v2` |
| `meterName`   | Tier name + component                     | `Standard Unit`, `Standard v2 Unit`, `Gateway Unit`        |

## Meter Names (verified 2026-02-06)

| Tier              | productName      | skuName       | meterName           | unitOfMeasure | Notes                         |
| ----------------- | ---------------- | ------------- | ------------------- | ------------- | ----------------------------- |
| Developer         | `API Management` | `Developer`   | `Developer Unit`    | `1 Hour`      | Non-SLA backed, dev/test only |
| Basic             | `API Management` | `Basic`       | `Basic Unit`        | `1 Hour`      | Classic tier                  |
| Standard          | `API Management` | `Standard`    | `Standard Unit`     | `1 Hour`      | Classic tier                  |
| Premium           | `API Management` | `Premium`     | `Premium Unit`      | `1 Hour`      | Classic, multi-region support |
| Basic v2          | `API Management` | `Basic v2`    | `Basic v2 Unit`     | `1 Hour`      | Newer tier                    |
| Standard v2       | `API Management` | `Standard v2` | `Standard v2 Unit`  | `1 Hour`      | Newer tier                    |
| Premium v2        | `API Management` | `Premium v2`  | `Premium v2 Unit`   | `1 Hour`      | Newer tier                    |
| Consumption       | `API Management` | `Consumption` | `Consumption Calls` | `10K`         | Per-call, not per-hour        |
| Gateway (classic) | `API Management` | `Gateway`     | `Gateway Unit`      | `1 Hour`      | Self-hosted gateway (classic) |
| Isolated          | `API Management` | `Isolated`    | `Isolated Unit`     | `1 Hour`      | Network-isolated              |

### Additional Meters (v2 tiers)

| Tier        | meterName                         | unitOfMeasure | Purpose                           |
| ----------- | --------------------------------- | ------------- | --------------------------------- |
| Basic v2    | `Basic v2 Secondary Unit`         | `1 Hour`      | Additional units beyond the first |
| Standard v2 | `Standard v2 Secondary Unit`      | `1 Hour`      | Additional units beyond the first |
| Standard v2 | `Standard v2 Self-hosted Gateway` | `1 Hour`      | Self-hosted gateway instances     |
| Premium v2  | `Premium v2 Secondary Unit`       | `1 Hour`      | Additional units beyond the first |
| Premium v2  | `Premium v2 Self-hosted Gateway`  | `1 Hour`      | Self-hosted gateway instances     |
| Premium     | `Secondary Unit`                  | `1 Hour`      | Additional Premium classic units  |

### Workspace Pack Meters

| Tier        | meterName                    | unitOfMeasure | Notes                            |
| ----------- | ---------------------------- | ------------- | -------------------------------- |
| Developer   | `Developer Workspace Pack`   | `1/Hour`      | API Management Workspaces add-on |
| Standard    | `Standard Workspace Pack`    | `1/Hour`      | API Management Workspaces add-on |
| Premium     | `Premium Workspace Pack`     | `1/Hour`      | API Management Workspaces add-on |
| Standard v2 | `Standard v2 Workspace Pack` | `1/Hour`      | API Management Workspaces add-on |
| Premium v2  | `Premium v2 Workspace Pack`  | `1/Hour`      | API Management Workspaces add-on |
| Isolated    | `Isolated Workspace Pack`    | `1/Hour`      | API Management Workspaces add-on |

## Cost Formula

```
# Hourly tiers (all except Consumption):
Monthly = retailPrice × 730 hours × unitCount

# Consumption tier:
Monthly = retailPrice × (apiCalls / 10,000)
  (first 1M calls/month free — check Azure docs for current free tier)

# Self-hosted Gateway (v2 tiers):
Monthly += gatewayPrice × 730 hours × gatewayCount

# Workspace Pack (if using API Management Workspaces):
Monthly += workspacePackPrice × 730 hours × packCount
```

## Reserved Instance Pricing

> **Note (verified 2026-02-06)**: API Management does **not** offer Reserved Instance pricing via the Retail Prices API. No results are returned for `-PriceType Reservation`.

## Common SKUs

| Tier        | Max APIs  | SLA          | Key Features                                              |
| ----------- | --------- | ------------ | --------------------------------------------------------- |
| Developer   | Unlimited | No SLA       | Dev/test only, no scale-out                               |
| Basic       | Unlimited | 99.95%       | 1,000 requests/sec, no VNet                               |
| Standard    | Unlimited | 99.95%       | 2,500 requests/sec, built-in cache                        |
| Premium     | Unlimited | 99.95–99.99% | Multi-region, VNet, self-hosted gateway, higher scale     |
| Basic v2    | Unlimited | 99.95%       | Newer architecture, network-integrated                    |
| Standard v2 | Unlimited | 99.95%       | Newer architecture, self-hosted gateway, VNet integration |
| Premium v2  | Unlimited | 99.95–99.99% | Newer architecture, multi-region, VNet, zone redundancy   |
| Consumption | 50        | 99.95%       | Serverless, per-call pricing, auto-scale                  |
