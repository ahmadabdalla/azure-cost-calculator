---
serviceName: Azure Database Migration Service
category: databases
aliases: [DMS, Database Migration, DB Migration Service]
primaryCost: "Instance hourly rate × 730 (all tiers have paid meters except 1-vCore Free)"
hasFreeGrant: true
---

# Azure Database Migration Service

> **Trap**: Meter names (`4 vCore`, `8 vCore`, `16 vCore`) repeat across General Purpose Compute and Premium Compute products. Always filter by `productName` to select the correct tier.

> **Trap (Free vs Paid meters)**: Only the `1 vCore vCore - Free` meter (Basic Compute) and General Purpose Storage return zero cost. All other Basic and General Purpose meters (`1 vCore`, `2 vCore`, `4 vCore`, `8 vCore`, `16 vCore`) have nonzero hourly rates. Do not assume Basic/General Purpose tiers are free — query the API and use the returned `retailPrice`.

> **Note**: Premium 4-vCore includes a 183-day free period per instance. Ask the user whether instances are still within the free period or provide the instance age to apply the grant deduction.

## Query Pattern

### Premium Compute (4 vCores, online migration)

ServiceName: Azure Database Migration Service
ProductName: Azure Database Migration Service Premium Compute
SkuName: 4 vCore
MeterName: 4 vCore
InstanceCount: 1 # number of DMS instances to provision

### General Purpose Compute (4 vCores, offline migration)

ServiceName: Azure Database Migration Service
ProductName: Azure Database Migration Service General Purpose Compute
SkuName: 4 vCore
MeterName: 4 vCore
InstanceCount: 1

## Key Fields

| Parameter     | How to determine                                     | Example values                                            |
| ------------- | ---------------------------------------------------- | --------------------------------------------------------- |
| `serviceName` | Always `Azure Database Migration Service`            | `Azure Database Migration Service`                        |
| `productName` | Tier: Basic, General Purpose, or Premium             | `...Basic Compute`, `...General Purpose Compute`, `...Premium Compute` |
| `skuName`     | vCore count                                          | `1 vCore`, `2 vCore`, `4 vCore`, `8 vCore`, `16 vCore`    |
| `meterName`   | Same as skuName; Basic free = `1 vCore vCore - Free` | `4 vCore`, `1 vCore vCore - Free`                         |

## Meter Names

| Meter                  | skuName    | productName                  | unitOfMeasure | Notes            |
| ---------------------- | ---------- | ---------------------------- | ------------- | ---------------- |
| `1 vCore vCore - Free` | `1 vCore`  | `...Basic Compute`           | `1 Hour`      | Always free      |
| `1 vCore`              | `1 vCore`  | `...Basic Compute`           | `1 Hour`      | Paid             |
| `2 vCore`              | `2 vCore`  | `...Basic Compute`           | `1 Hour`      | Paid             |
| `4 vCore`              | `4 vCore`  | `...General Purpose Compute` | `1 Hour`      | Paid             |
| `8 vCore`              | `8 vCore`  | `...General Purpose Compute` | `1 Hour`      | Paid             |
| `16 vCore`             | `16 vCore` | `...General Purpose Compute` | `1 Hour`      | Paid             |
| `4 vCore`              | `4 vCore`  | `...Premium Compute`         | `1 Hour`      | Paid (online)    |
| `8 vCore`              | `8 vCore`  | `...Premium Compute`         | `1 Hour`      | Paid (online)    |
| `16 vCore`             | `16 vCore` | `...Premium Compute`         | `1 Hour`      | Paid (online)    |
| `General Purpose Data Stored - Free` | `General Purpose` | `...General Purpose Storage` | `1 GB/Month` | Always free |

## Cost Formula

```
Basic / General Purpose = compute_retailPrice × 730 × instanceCount
Premium (outside free period) = compute_retailPrice × 730 × instanceCount
Premium 4-vCore (within 183-day free period) = max(0, totalHours - remainingFreeGrantHours) × compute_retailPrice × instanceCount
Storage = free (retailPrice returns 0)
Total = sum of applicable tier costs
```

## Notes

- Only `1 vCore vCore - Free` (Basic) and Storage meters are zero cost; all other meters have nonzero rates
- Basic tier (1–2 vCores) and General Purpose (4, 8, 16 vCores): paid per-vCore/hour for offline migrations
- Premium tier (4, 8, 16 vCores): paid per-vCore/hour for online (continuous-sync) migrations
- Premium 4-vCore includes a 183-day free period per instance; ask for instance age or planned migration duration
- Capacity: 4 vCores supports ~2 parallel table migrations; scale up for larger databases
- Storage (General Purpose Storage) is always free (zero cost)
- Often deployed via Azure Migrate hub (see migrate.md for migration project costing)
- Classic DMS retired March 2026; new experience uses Azure portal or Azure SQL Migration extension

## Product Names

| Config          | productName                                                |
| --------------- | ---------------------------------------------------------- |
| Basic           | `Azure Database Migration Service Basic Compute`           |
| General Purpose | `Azure Database Migration Service General Purpose Compute` |
| Premium         | `Azure Database Migration Service Premium Compute`         |
| Storage         | `Azure Database Migration Service General Purpose Storage` |
