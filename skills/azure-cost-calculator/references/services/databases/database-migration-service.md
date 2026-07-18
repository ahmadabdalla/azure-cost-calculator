---
serviceName: Azure Database Migration Service
category: databases
aliases: [DMS, Database Migration, DB Migration Service]
primaryCost: "Standard/offline is free; Premium or legacy compute uses retailPrice × 730 × instanceCount"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Database Migration Service

> **Trap**: Meter names (`4 vCore`, `8 vCore`, `16 vCore`) repeat across General Purpose Compute and Premium Compute products. Always filter by `productName` to select the correct tier.

> **Trap (Standard vs legacy meters)**: Microsoft pricing docs list Standard Compute (1, 2, and 4 vCores) as free, but the Retail Prices API still returns legacy Basic and General Purpose compute meters with nonzero rates. For modern offline/Standard migrations, treat compute as free. For existing classic instances or explicit API-meter estimates, query the API and use the returned `retailPrice`.

> **Note**: Premium 4-vCore includes a 183-day free period per instance. Ask whether instances are still within the free period or provide the instance age to apply the grant deduction.

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

### Premium 4-vCore free-grant confirmation

ServiceName: Azure Database Migration Service
ProductName: Azure Database Migration Service Premium Compute
SkuName: 4 vCore
MeterName: 4 vCore
Region: Global

## Key Fields

| Parameter     | How to determine                                      | Example values                                            |
| ------------- | ----------------------------------------------------- | --------------------------------------------------------- |
| `serviceName` | Always `Azure Database Migration Service`             | `Azure Database Migration Service`                        |
| `productName` | Tier: Basic, General Purpose, Premium, or Storage     | `...Basic Compute`, `...General Purpose Compute`, `...Premium Compute` |
| `skuName`     | vCore count or `General Purpose` for storage          | `1 vCore`, `2 vCore`, `4 vCore`, `8 vCore`, `16 vCore`    |
| `meterName`   | Same as skuName; Basic free and storage add suffixes  | `4 vCore`, `1 vCore vCore - Free`, `General Purpose Data Stored - Free` |

## Meter Names

| Meter                  | skuName    | productName                  | unitOfMeasure | Notes            |
| ---------------------- | ---------- | ---------------------------- | ------------- | ---------------- |
| `1 vCore vCore - Free` | `1 vCore`  | `...Basic Compute`           | `1 Hour`      | Free legacy row  |
| `1 vCore`              | `1 vCore`  | `...Basic Compute`           | `1 Hour`      | Legacy paid row  |
| `2 vCore`              | `2 vCore`  | `...Basic Compute`           | `1 Hour`      | Legacy paid row  |
| `4 vCore`              | `4 vCore`  | `...General Purpose Compute` | `1 Hour`      | Legacy paid row  |
| `8 vCore`              | `8 vCore`  | `...General Purpose Compute` | `1 Hour`      | Legacy paid row  |
| `16 vCore`             | `16 vCore` | `...General Purpose Compute` | `1 Hour`      | Legacy paid row  |
| `4 vCore`              | `4 vCore`  | `...Premium Compute`         | `1 Hour`      | Paid after grant |
| `8 vCore`              | `8 vCore`  | `...Premium Compute`         | `1 Hour`      | API legacy size  |
| `16 vCore`             | `16 vCore` | `...Premium Compute`         | `1 Hour`      | API legacy size  |
| `General Purpose Data Stored - Free` | `General Purpose` | `...General Purpose Storage` | `1 GB/Month` | Free; two tier rows |

## Cost Formula

```
Modern Standard/offline = 0 (Microsoft pricing docs list Standard Compute as free)
Legacy Basic / General Purpose = compute_retailPrice × 730 × instanceCount
Premium after free period = compute_retailPrice × 730 × instanceCount
Premium 4-vCore within 183-day free period = max(0, totalHours - remainingFreeGrantHours) × compute_retailPrice × instanceCount
Storage = free (retailPrice returns 0)
Total = sum of applicable tier costs
```

## Notes

- Microsoft pricing docs list Standard tier (1, 2, and 4 vCores) as free for offline migrations
- The API still exposes legacy Basic and General Purpose paid meters; use them only for existing classic instances or explicit API-meter estimates
- Premium tier is required for online migrations; 4-vCore includes a 183-day free period per instance
- Premium 8-vCore and 16-vCore meters exist in the API, but public pricing docs focus on 4-vCore
- Capacity: 4 vCores supports ~2 parallel table migrations; scale up for larger databases
- Storage (General Purpose Storage) returns two zero-priced tier rows (`TierMinUnits` 0 and 50)
- DMS can connect to source and target databases using private endpoints; price those endpoint resources separately
- Often deployed via Azure Migrate hub (see migrate.md for migration project costing)
- Classic DMS retired March 2026; classic instances have a one-year maximum lifetime from creation
- Pricing page mentions a database savings plan for Premium vCores, but the Retail Prices API returned no reservation or savings-plan price rows

## Product Names

| Config          | productName                                                |
| --------------- | ---------------------------------------------------------- |
| Basic legacy    | `Azure Database Migration Service Basic Compute`           |
| GP legacy       | `Azure Database Migration Service General Purpose Compute` |
| Premium         | `Azure Database Migration Service Premium Compute`         |
| Storage         | `Azure Database Migration Service General Purpose Storage` |
