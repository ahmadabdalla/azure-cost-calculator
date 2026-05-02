---
serviceName: Azure App Service
category: compute
aliases: [Web Apps, App Service Plan, ASP]
billingConsiderations: [Reserved Instances]
primaryCost: "Hourly rate for plan SKU × 730 × instanceCount"
privateEndpoint: true
---

# Azure App Service

> **Trap (productName OS variants)**: Windows plans use no OS suffix (e.g., `Azure App Service Premium v3 Plan`); Linux plans append `- Linux`. Querying the wrong variant returns a different price or zero results.

> **Trap (Isolated platform fees)**: Isolated v1 has a mandatory `Stamp Fee` and Isolated v2 has an `ASIP` platform fee. Both are per-ASE hourly charges in addition to instance compute costs.

## Query Pattern

### Linux Premium v3 (use InstanceCount for multiple instances)

ServiceName: Azure App Service
ProductName: Azure App Service Premium v3 Plan - Linux
SkuName: P1 v3
InstanceCount: 2

### Windows Premium v3

ServiceName: Azure App Service
ProductName: Azure App Service Premium v3 Plan
SkuName: P1 v3

### Premium v4: Linux (note: no space in skuName for v4 tier)

ServiceName: Azure App Service
ProductName: Azure App Service Premium v4 Plan - Linux
SkuName: P1v4

### Isolated v2: platform fee (per ASE, in addition to instance cost)

ServiceName: Azure App Service
ProductName: Azure App Service Isolated v2 Plan - Linux
SkuName: ASIP

## Key Fields

| Parameter     | How to determine       | Example values                               |
| ------------- | ---------------------- | -------------------------------------------- |
| `productName` | Plan tier + OS variant | See Product Names table                      |
| `skuName`     | Plan tier + size or fee | `B1`, `S1`, `P1 v3`, `P1v4`, `I1`, `I1 v2`, `Stamp`, `ASIP` |

## Cost Formula

```
Monthly = retailPrice × 730 × instanceCount
Isolated v1/v2 = (platformFee_retailPrice × 730) + (instance_retailPrice × 730 × instanceCount)
```

## Notes

- Plans are billed whether or not apps are running. Delete the plan to stop billing, not just the apps
- Multiple apps share one plan; cost is per-plan, not per-app
- Free (F1) and Shared (D1) tiers exist but are not recommended for production
- **Functions on Dedicated plans** (B1/S1/P1v3) bill through App Service; no meters under `Functions`
- **Logic Apps Standard** creates WS-type plans but bills through `Logic Apps` meters, not App Service
- Private endpoints require Basic tier or higher
- RIs are available for Premium v3, Premium v4, and Isolated v2 compute. For Isolated v1, only the `Stamp Fee` reservation is available (3-Year); Isolated v1 compute SKUs (`I1`, `I2`, `I3`) do not return reservation rows. RIs are not available for Basic, Standard, or Premium v2
- Meter naming varies: Linux Basic uses `B1`/`B2`/`B3`; Premium v4 uses `P0v4`/`P1v4`; ASIP/IDH meters use bare names; other tiers append `App` (e.g., `P0v3 App`, `P1 v3 App`)
- Memory-optimized variants (`P1mv3`, `P1mv4`, `I1mv2`) offer higher memory-to-CPU ratios at a premium
- Isolated v2 scales up to `I6 v2` and includes `IDH v2` (Dedicated Host, Windows-only); Isolated v1 includes `I12`/`I13`/`I14` large SKUs and a `Front End` per-ASE meter

## Product Names

| Tier        | Linux                                        | Windows                              |
| ----------- | -------------------------------------------- | ------------------------------------ |
| Basic       | `Azure App Service Basic Plan - Linux`       | `Azure App Service Basic Plan`       |
| Standard    | `Azure App Service Standard Plan - Linux`    | `Azure App Service Standard Plan`    |
| Premium v2  | `Azure App Service Premium v2 Plan - Linux`  | `Azure App Service Premium v2 Plan`  |
| Premium v3  | `Azure App Service Premium v3 Plan - Linux`  | `Azure App Service Premium v3 Plan`  |
| Premium v4  | `Azure App Service Premium v4 Plan - Linux`  | `Azure App Service Premium v4 Plan`  |
| Isolated v1 | `Azure App Service Isolated Plan - Linux`    | `Azure App Service Isolated Plan`    |
| Isolated v2 | `Azure App Service Isolated v2 Plan - Linux` | `Azure App Service Isolated v2 Plan` |

## Common SKUs

| SKU     | vCPUs | RAM (GB) | Tier        |
| ------- | ----- | -------- | ----------- |
| `B1`    | 1     | 1.75     | Basic       |
| `S1`    | 1     | 1.75     | Standard    |
| `P1 v2` | 1     | 3.5      | Premium v2  |
| `P0v3`  | 1     | 4        | Premium v3  |
| `P1 v3` | 2     | 8        | Premium v3  |
| `P1v4`  | 2     | 8        | Premium v4  |
| `I1 v2` | 2     | 8        | Isolated v2 |

## Reserved Instance Pricing

ServiceName: Azure App Service
ProductName: Azure App Service Premium v3 Plan - Linux
SkuName: P1 v3
PriceType: Reservation
