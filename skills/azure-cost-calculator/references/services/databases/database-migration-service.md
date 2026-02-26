---
serviceName: Azure Database Migration Service
category: databases
aliases: [DMS, Database Migration, DB Migration Service]
primaryCost: "Instance hourly rate × 730 (Premium tier only — Basic/General Purpose are free)"
hasFreeGrant: true
---

# Azure Database Migration Service

> **Trap**: Meter names (`4 vCore`, `8 vCore`, `16 vCore`) repeat across General Purpose Compute and Premium Compute products. Always filter by `productName` to select the correct tier.

> **Note**: Basic and General Purpose tiers are free for offline migrations. Only Premium tier incurs charges for online (continuous-sync) migrations — with a 183-day free period per instance.

## Query Pattern

### Premium Compute (4 vCores, online migration)

ServiceName: Azure Database Migration Service
ProductName: Azure Database Migration Service Premium Compute
SkuName: 4 vCore
MeterName: 4 vCore
InstanceCount: 1 # number of DMS instances to provision

### General Purpose Compute (4 vCores, offline — free)

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

| Meter                  | skuName    | productName                  | unitOfMeasure | Notes          |
| ---------------------- | ---------- | ---------------------------- | ------------- | -------------- |
| `1 vCore vCore - Free` | `1 vCore`  | `...Basic Compute`           | `1 Hour`      | Always free    |
| `1 vCore`              | `1 vCore`  | `...Basic Compute`           | `1 Hour`      | Paid Basic     |
| `2 vCore`              | `2 vCore`  | `...Basic Compute`           | `1 Hour`      | Paid Basic     |
| `4 vCore`              | `4 vCore`  | `...General Purpose Compute` | `1 Hour`      | Free (offline) |
| `8 vCore`              | `8 vCore`  | `...General Purpose Compute` | `1 Hour`      | Free (offline) |
| `16 vCore`             | `16 vCore` | `...General Purpose Compute` | `1 Hour`      | Free (offline) |
| `4 vCore`              | `4 vCore`  | `...Premium Compute`         | `1 Hour`      | Paid (online)  |
| `8 vCore`              | `8 vCore`  | `...Premium Compute`         | `1 Hour`      | Paid (online)  |
| `16 vCore`             | `16 vCore` | `...Premium Compute`         | `1 Hour`      | Paid (online)  |

Storage meters (General Purpose Storage) omitted — always zero cost.

## Cost Formula

```
Premium = compute_retailPrice × 730 × instanceCount
Basic / General Purpose = free (retailPrice returns 0)
Storage = free (retailPrice returns 0)
Total = Premium (if online migration required)
```

## Notes

- Basic and General Purpose tiers (offline): free — supports SQL Server, MySQL, PostgreSQL, MongoDB migrations
- Premium tier (online/continuous-sync): paid per-vCore/hour after 183-day free period
- Premium is ~2× General Purpose pricing for the same vCore count
- Basic tier: 1–2 vCores; General Purpose / Premium: 4, 8, or 16 vCores
- Capacity: 4 vCores supports ~2 parallel table migrations; scale up for larger databases
- Storage (General Purpose Storage) is always free (zero cost)
- Often deployed via Azure Migrate hub — see migrate.md for migration project costing
- Classic DMS is retiring March 2026; new experience uses Azure portal or Azure SQL Migration extension

## Product Names

| Config          | productName                                                |
| --------------- | ---------------------------------------------------------- |
| Basic           | `Azure Database Migration Service Basic Compute`           |
| General Purpose | `Azure Database Migration Service General Purpose Compute` |
| Premium         | `Azure Database Migration Service Premium Compute`         |
| Storage         | `Azure Database Migration Service General Purpose Storage` |
