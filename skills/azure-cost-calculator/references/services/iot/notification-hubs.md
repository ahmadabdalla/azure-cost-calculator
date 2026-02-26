---
serviceName: Notification Hubs
category: iot
aliases: [Push Notifications, ANH]
primaryCost: "Per-namespace monthly flat rate by tier (Free/Basic/Standard) + per-million push overages beyond quota"
hasFreeGrant: true
privateEndpoint: true
---

# Notification Hubs

> **Trap (tiered pricing inflation)**: Querying Basic or Standard tiers without `MeterName` returns **multiple tiered pricing rows** for the overage meters. The script sums all tier rows, inflating `totalMonthlyCost` above the actual base price. For base cost estimation, filter to the base unit meter only (`Basic Unit` or `Standard Unit`). Overage tiers apply only when usage exceeds the included 10M pushes/month.

> **Trap (namespace billing)**: Base charges are per namespace — use `InstanceCount: N` to model multi-namespace deployments. The included push quota (10M for Basic/Standard) is aggregated **per subscription per tier**, not per namespace.

## Query Pattern

### Standard tier — base subscription (10M pushes included)

ServiceName: Notification Hubs
SkuName: Standard
MeterName: Standard Unit

### Basic tier — base subscription (10M pushes included)

ServiceName: Notification Hubs
SkuName: Basic
MeterName: Basic Unit

### Free tier — base subscription (1M pushes included)

ServiceName: Notification Hubs
SkuName: Free
MeterName: Free Unit

### Multi-namespace deployment — 3 Standard namespaces

ServiceName: Notification Hubs
SkuName: Standard
MeterName: Standard Unit
InstanceCount: 3

### Standard overage — pushes beyond 10M (Quantity in millions)

ServiceName: Notification Hubs
SkuName: Standard
MeterName: Standard Pushes
Quantity: 5

### Private Link add-on (stacks with base tier)

ServiceName: Notification Hubs
SkuName: Private Link
MeterName: Private Link Unit

### Availability Zones add-on (stacks with base tier)

ServiceName: Notification Hubs
SkuName: Availability Zones SKU
MeterName: Availability Zones Unit

## Key Fields

| Parameter     | How to determine                          | Example values                                                                                     |
| ------------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Notification Hubs`                | `Notification Hubs`                                                                                |
| `skuName`     | Tier or add-on feature                    | `Free`, `Basic`, `Standard`, `1P Direct Send`, `Private Link`, `Availability Zones SKU`            |
| `meterName`   | Base unit, overage pushes, or add-on unit | `Free Unit`, `Basic Unit`, `Standard Unit`, `Basic Pushes`, `Standard Pushes`, `Private Link Unit` |

## Meter Names

| Meter                     | SKU                    | unitOfMeasure | Notes                                       |
| ------------------------- | ---------------------- | ------------- | ------------------------------------------- |
| `Free Unit`               | Free                   | 1/Month       | 1M pushes/month hard limit                  |
| `Basic Unit`              | Basic                  | 1/Month       | Base subscription, 10M pushes included      |
| `Basic Pushes`            | Basic                  | 1M            | Overage beyond 10M (TierMinUnits: 10.0)     |
| `Standard Unit`           | Standard               | 1/Month       | Base subscription, 10M pushes included      |
| `Standard Pushes`         | Standard               | 1M            | Tiered overage: tier 1 @ 10M, tier 2 @ 100M |
| `1P Direct Send Pushes`   | 1P Direct Send         | 1M            | First-party direct send capability          |
| `Private Link Unit`       | Private Link           | 1/Month       | Private endpoint add-on                     |
| `Availability Zones Unit` | Availability Zones SKU | 1/Month       | Zone-redundancy add-on                      |

## Cost Formula

```
Free monthly     = 0 (hard limit: 1M pushes/month)
Basic monthly    = basic_retailPrice × instanceCount + max(0, (pushes - 10M) / 1M) × basicOverage_retailPrice
Standard monthly = standard_retailPrice × instanceCount + overage_cost
  where overage_cost = max(0, min(pushes - 10M, 90M) / 1M) × standardOverageTier1_retailPrice
                     + max(0, (pushes - 100M) / 1M) × standardOverageTier2_retailPrice
Add-ons          = (privateLink_retailPrice + availabilityZones_retailPrice) × instanceCount
Total            = base + overage + add-ons  (pushes = subscription-level aggregate per tier)
```

## Notes

- **Tiers**: Free (1M pushes/month hard limit), Basic (monthly base + 10M included, then overage), Standard (monthly base + 10M included, then tiered overages: tier 1 for 10-100M, tier 2 for 100M+)
- Included push quotas (10M for Basic/Standard) are aggregated **per subscription per tier**, not per namespace
- Capacity: Standard namespace supports up to 10M active devices; 10M pushes/month included per subscription
- Private Link and Availability Zones are per-namespace add-ons; 1P Direct Send is usage-based (no base subscription)
