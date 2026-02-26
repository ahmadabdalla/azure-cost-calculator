---
serviceName: Azure Managed Grafana
category: developer-tools
aliases: [Managed Grafana, Azure Grafana Service, Grafana Dashboard]
apiServiceName: Azure Grafana Service
primaryCost: "Per-instance hourly (Standard Units × 730) + per active user/month"
privateEndpoint: true
---

# Azure Managed Grafana

> **Trap (instance multiplier)**: The `Standard Node` meter prices 1 Standard Unit (SU), not 1 instance. Standard X1 uses 2 SUs; X2 uses 4 SUs. Similarly, `Standard Zone Redundancy` prices 1 ZRU — X1 needs 1 ZRU, X2 needs 2. Always set `Quantity` to the correct SU/ZRU count for the target instance size.

> **Trap (unfiltered query)**: Querying with only `ServiceName` mixes Essential and Standard meters with different billing units (`1/Month` vs `1/Hour`), producing a meaningless total. Always filter by `SkuName` and `MeterName`.

## Query Pattern

### Standard X1 instance — most common production config

ServiceName: Azure Grafana Service <!-- cross-service -->
ProductName: Azure Managed Grafana
SkuName: Standard
MeterName: Standard Node
Quantity: 2

### Standard zone redundancy (additive to node cost)

ServiceName: Azure Grafana Service <!-- cross-service -->
ProductName: Azure Managed Grafana
SkuName: Standard
MeterName: Standard Zone Redundancy

### Standard active users

ServiceName: Azure Grafana Service <!-- cross-service -->
ProductName: Azure Managed Grafana
SkuName: Standard
MeterName: Standard User
Quantity: 5

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `Azure Grafana Service` | `Azure Grafana Service` |
| `productName` | Always `Azure Managed Grafana` | `Azure Managed Grafana` |
| `skuName` | Tier selection (never-assume) | `Essential`, `Standard` |
| `meterName` | Billing component | `Standard Node`, `Standard User`, `Standard Zone Redundancy` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `Essential User` | `Essential` | `1/Month` | Per active user; no instance meter for Essential |
| `Standard Node` | `Standard` | `1/Hour` | Per Standard Unit (SU) — X1=2 SU, X2=4 SU |
| `Standard User` | `Standard` | `1/Month` | Per active user; flat rate across all regions |
| `Standard Zone Redundancy` | `Standard` | `1/Hour` | Per ZRU — X1=1 ZRU, X2=2 ZRU; additive |

## Cost Formula

```
Standard Monthly = node_retailPrice × 730 × SU_count
                 + zr_retailPrice × 730 × ZRU_count
                 + user_retailPrice × active_users
Essential Monthly = user_retailPrice × active_users
```

## Notes

- **Essential tier (Preview, being deprecated)**: No instance charge — user-only billing. Limited to 1 workspace/subscription, 20 dashboards, 5 data sources. Being replaced by Standard tier and Azure Monitor dashboards
- **Instance sizes**: Standard X1 (default) = 2 SUs, Standard X2 = 4 SUs. Instance size determines SU/ZRU quantity multiplier (never-assume)
- **Active users**: Counted per Azure subscription, not per instance — includes users, service accounts, and API keys
- **30-day free trial**: First instance free for 30 days (one per subscription) — not reflected in API pricing
- **Private Endpoints**: Supported on Standard tier only — not available on Essential; see `networking/private-link.md` for PE and DNS zone pricing
