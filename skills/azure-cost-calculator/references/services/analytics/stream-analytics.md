---
serviceName: Stream Analytics
category: analytics
aliases: [ASA, Real-time Analytics]
primaryCost: "Streaming Unit (SU) hourly rate × 730 per SU provisioned"
privateEndpoint: true
---

# Azure Stream Analytics

> **Trap (V2 tiered pricing)**: Standard V2 and Dedicated V2 return multiple rows with tiered pricing (TierMinUnits 0, 730, 5840). The rate varies by tier — check each row's `unitPrice` and `tierMinimumUnits` to apply the correct rate per usage band. `totalMonthlyCost` sums all tiers and is misleading. Use `SkuName 'Standard'` (legacy, single flat rate) for simple estimates, or filter V2 rows by TierMinUnits for accurate tiered calculations.

> **Trap (Edge pricing)**: `Stream Analytics on Edge` uses `1/Month` billing and a different `productName`. Do not mix cloud and Edge meters in the same query.

## Query Pattern

### Standard tier — single SU (legacy, flat hourly rate)

ServiceName: Stream Analytics
SkuName: Standard

### Standard tier — 6 SU deployment (InstanceCount = number of Streaming Units)

ServiceName: Stream Analytics
SkuName: Standard
InstanceCount: 6

### Standard V2 tier (current, tiered pricing — returns multiple rows)

ServiceName: Stream Analytics
SkuName: Standard V2

### Edge deployment — per device/month

ServiceName: Stream Analytics
ProductName: Stream Analytics on Edge

### All cloud tiers (excludes Edge)

ServiceName: Stream Analytics
ProductName: Stream Analytics

## Key Fields

| Parameter     | How to determine                        | Example values                                     |
| ------------- | --------------------------------------- | -------------------------------------------------- |
| `serviceName` | Always `Stream Analytics`               | `Stream Analytics`                                 |
| `productName` | Cloud vs Edge deployment                | `Stream Analytics`, `Stream Analytics on Edge`     |
| `skuName`     | Tier selection                          | `Standard`, `Standard V2`, `Dedicated`, `Dedicated V2` |
| `meterName`   | Billing meter for the tier              | `Standard Streaming Unit`, `Standard V2 Streaming Unit/Job` |

## Meter Names

| Meter                               | skuName        | unitOfMeasure | Notes                              |
| ----------------------------------- | -------------- | ------------- | ---------------------------------- |
| `Standard Streaming Unit`           | `Standard`     | `1 Hour`      | Legacy flat rate per SU            |
| `Standard V2 Streaming Unit/Job`    | `Standard V2`  | `1 Hour`      | Current tier, tiered pricing       |
| `Dedicated Streaming Unit`          | `Dedicated`    | `1 Hour`      | Legacy dedicated flat rate         |
| `Dedicated V2 Streaming Unit/Job`   | `Dedicated V2` | `1 Hour`      | Current dedicated, tiered pricing  |
| `S1 Device`                         | `S1`           | `1/Month`     | Edge deployment per device         |

## Cost Formula

```
Standard (legacy): Monthly = retailPrice × 730 × suCount
Standard V2:       Monthly = Σ(tier_retailPrice × hours_in_tier) × suCount
Edge:              Monthly = retailPrice × deviceCount
```

## Notes

- **Capacity per SU**: 1 Streaming Unit ≈ 1 MB/s input throughput; complex queries (joins, aggregates, windowed functions) require more SUs for the same data volume
- **Standard vs V2**: Standard (legacy) has a single flat hourly rate; Standard V2 (current) uses tiered pricing with three bands (TierMinUnits 0, 730, 5840) — query the API and check each row's `unitPrice` to compare
- **Dedicated tiers**: Same pricing as Standard counterparts; substitute `SkuName: Dedicated` or `Dedicated V2` in query patterns for isolated, high-throughput workloads
- **Edge**: Per-device monthly flat rate; runs on IoT Edge devices for local stream processing
- **No ArmSkuName**: All meters return empty `armSkuName` — do not filter by this field
- Private endpoints require a Stream Analytics cluster (Dedicated tiers); Standard tier cloud jobs do not support PE
