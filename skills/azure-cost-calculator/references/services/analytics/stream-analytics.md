---
serviceName: Stream Analytics
category: analytics
aliases: [ASA, Real-time Analytics]
---

# Azure Stream Analytics

**Primary cost**: Streaming Unit (SU) hourly rate × 730 per SU provisioned

> **Trap (V2 tiered pricing)**: Standard V2 and Dedicated V2 return multiple rows with tiered pricing (TierMinUnits 0, 730, 5840). The base tier row ($0.33/hour) is the highest rate — higher tiers are volume discounts. `totalMonthlyCost` sums all tiers and is misleading. Use `SkuName 'Standard'` (legacy, flat $0.11/hour) for simple estimates, or filter V2 rows by TierMinUnits for accurate tiered calculations.

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
| `Standard Streaming Unit`           | `Standard`     | `1 Hour`      | Legacy flat rate ($0.11/hr)        |
| `Standard V2 Streaming Unit/Job`    | `Standard V2`  | `1 Hour`      | Current tier, tiered pricing       |
| `Dedicated Streaming Unit`          | `Dedicated`    | `1 Hour`      | Legacy dedicated ($0.11/hr)        |
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
- **Standard vs V2**: Standard (legacy) has flat $0.11/SU/hour; Standard V2 (current) starts at $0.33/SU/hour but offers volume discounts at 730+ and 5,840+ SU-hours
- **Dedicated**: Same pricing structure as Standard (legacy flat rate vs V2 tiered); intended for isolated, high-throughput workloads
- **Edge**: Flat $1.00/device/month; runs on IoT Edge devices for local stream processing
- **No ArmSkuName**: All meters return empty `armSkuName` — do not filter by this field
- Reserved pricing is **not available** — `PriceType Reservation` returns 0 results
