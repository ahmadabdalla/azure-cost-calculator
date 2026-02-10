---
serviceName: API Management
category: integration
aliases: [APIM, API gateway, API management]
---

# API Management

**Primary cost**: Unit hours based on tier

> **Trap (multiple meters)**: Tiers have multiple meters (e.g., `Standard v2 Unit`, `Secondary Unit`, `Self-hosted Gateway`, `Calls`). Use the primary `{Tier} Unit` meter for base cost. Secondary units, gateways, and workspace packs are additional — only include if user requests.
> **Trap (v2 Calls)**: v2 tiers have a `Calls` meter at `$0.00/10K` — ignore in estimates.
> **Trap (Consumption)**: Uses per-call pricing (`Consumption Calls`), not hourly units. Do NOT multiply by 730.

## Query Pattern

# All tiers — substitute {Tier} from Meter Names table

ServiceName: API Management
SkuName: {Tier}
MeterName: {Tier} Unit

# v2 secondary units: MeterName '{Tier} Secondary Unit'

# Self-hosted gateway (Std v2/Prem v2): MeterName '{Tier} Self-hosted Gateway'

## Key Fields

| Parameter     | How to determine                          | Example values                                             |
| ------------- | ----------------------------------------- | ---------------------------------------------------------- |
| `productName` | Always `API Management`                   | `API Management`                                           |
| `skuName`     | Tier name — this selects the pricing tier | `Developer`, `Basic`, `Standard`, `Premium`, `Standard v2` |
| `meterName`   | Tier name + component                     | `Standard Unit`, `Standard v2 Unit`, `Gateway Unit`        |

## Meter Names

| Tier        | skuName       | meterName           | unitOfMeasure | Notes                         |
| ----------- | ------------- | ------------------- | ------------- | ----------------------------- |
| Developer   | `Developer`   | `Developer Unit`    | `1 Hour`      | No SLA, dev/test only         |
| Basic       | `Basic`       | `Basic Unit`        | `1 Hour`      | Classic tier                  |
| Standard    | `Standard`    | `Standard Unit`     | `1 Hour`      | Classic tier                  |
| Premium     | `Premium`     | `Premium Unit`      | `1 Hour`      | Multi-region support          |
| Basic v2    | `Basic v2`    | `Basic v2 Unit`     | `1 Hour`      | Newer architecture            |
| Standard v2 | `Standard v2` | `Standard v2 Unit`  | `1 Hour`      | Newer, VNet, self-hosted gw   |
| Premium v2  | `Premium v2`  | `Premium v2 Unit`   | `1 Hour`      | Newer, multi-region, VNet     |
| Consumption | `Consumption` | `Consumption Calls` | `10K`         | Per-call, not per-hour        |
| Gateway     | `Gateway`     | `Gateway Unit`      | `1 Hour`      | Self-hosted gateway (classic) |
| Isolated    | `Isolated`    | `Isolated Unit`     | `1 Hour`      | Network-isolated              |

> **Additional meters**: v2 tiers have `{Tier} Secondary Unit` and `{Tier} Self-hosted Gateway` (1 Hour each). Premium classic has `Secondary Unit`.
> **Workspace Packs**: Available for Developer, Standard, Premium, Standard v2, Premium v2, Isolated — query with `{Tier} Workspace Pack` meter (1/Hour).

## Cost Formula

```
# Hourly tiers: Monthly = retailPrice × 730 × unitCount
# Consumption:  Monthly = retailPrice × (apiCalls / 10,000)  [first 1M calls/month free]
# Add-ons:      Monthly += componentPrice × 730 × count  (secondary units, gateways, workspace packs)
```

## Common SKUs

| Tier        | SLA          | Key Features                                  |
| ----------- | ------------ | --------------------------------------------- |
| Developer   | No SLA       | Dev/test only, no scale-out                   |
| Basic       | 99.95%       | 1,000 req/sec, no VNet                        |
| Standard    | 99.95%       | 2,500 req/sec, built-in cache                 |
| Premium     | 99.95–99.99% | Multi-region, VNet, self-hosted gateway       |
| Basic v2    | 99.95%       | Newer architecture, network-integrated        |
| Standard v2 | 99.95%       | Self-hosted gateway, VNet integration         |
| Premium v2  | 99.95–99.99% | Multi-region, VNet, zone redundancy           |
| Consumption | 99.95%       | Serverless, per-call, auto-scale, max 50 APIs |

## Notes

- API Management does **not** offer Reserved Instance pricing.
- All tiers support unlimited APIs except Consumption (max 50).
- `productName` is always `API Management` for all tiers.
