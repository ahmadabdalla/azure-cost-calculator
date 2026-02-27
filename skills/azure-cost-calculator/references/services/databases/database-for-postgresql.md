---
serviceName: Azure Database for PostgreSQL
category: databases
aliases: [PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server]
billingConsiderations: [Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure Database for PostgreSQL Flexible Server

> **Trap**: `productName` has inconsistent hyphen usage across series. Some use `General Purpose - Ddsv5` (with hyphen) while others use `General Purpose Dadsv5` (no hyphen). Always use the exact string from discovery — do not construct productName by pattern.

## Query Pattern

### Compute cost (General Purpose, Ddsv5 series, 4 vCore)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv5 Series Compute
SkuName: 4 vCore
MeterName: vCore

### Storage cost (100 GB)

ServiceName: Azure Database for PostgreSQL
ProductName: Az DB for PostgreSQL Flexible Server Storage
SkuName: Storage
MeterName: Storage Data Stored
Quantity: 100 # storage size in GB

## Key Fields

| Parameter     | How to determine             | Example values                                       |
| ------------- | ---------------------------- | ---------------------------------------------------- |
| `productName` | Tier + series (exact match)  | See Product Names table below                        |
| `skuName`     | vCore count string           | `'2 vCore'`, `'4 vCore'`, `'8 vCore'`, `'16 vCore'` |
| `meterName`   | Always `'vCore'` for compute | `'vCore'`, `'Storage Data Stored'`                   |

## Meter Names

| Meter                            | skuName             | unitOfMeasure | Notes                                  |
| -------------------------------- | ------------------- | ------------- | -------------------------------------- |
| `vCore`                          | `N vCore`           | `1 Hour`      | Per-vCore rate; N determines vCore count |
| `Storage Data Stored`            | `Storage`           | `1 GB/Month`  | Standard LRS data storage              |
| `Backup Storage LRS Data Stored` | `Backup Storage LRS` | `1 GB/Month` | Backup beyond free grant               |

## Cost Formula

```
Monthly Compute = unitPrice × 730
Monthly Storage = storage_retailPrice × sizeGB
Total = Compute + Storage
```

## Notes

- Burstable: dev/test workloads, does NOT support RI. Uses fixed SKU names (B1MS, B4ms, etc.)
- GP: production workloads, supports RI. Uses `SkuName: N vCore` to select size
- MO: high-memory workloads, supports RI. Same per-vCore pattern as GP
- High Availability doubles compute cost (deploys a standby replica)
- Backup storage: first backup equal to DB size is free; excess charged per-GB/month
- Single Server is deprecated — all new deployments use Flexible Server
- Cosmos DB for PostgreSQL and HorizonDB meters share this serviceName — filter by productName to isolate Flexible Server

## Product Names

| Config         | productName                                                                            |
| -------------- | -------------------------------------------------------------------------------------- |
| GP, Ddsv5      | `Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv5 Series Compute` |
| GP, Dadsv5     | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv5 Series Compute`  |
| GP, Ddsv6      | `Azure Database for PostgreSQL Flexible Server General Purpose Ddsv6 Series Compute`   |
| GP, Dadsv6     | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv6 Series Compute`  |
| MO, Edsv5      | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv5 Series Compute`  |
| MO, Eadsv5     | `Azure Database for PostgreSQL Flexible Server Memory Optimized Eadsv5 Series Compute` |
| MO, Edsv6      | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv6 Series Compute`  |
| Burstable, BS  | `Azure Database for PostgreSQL Flexible Server Burstable BS Series Compute`            |
| Storage        | `Az DB for PostgreSQL Flexible Server Storage`                                         |

> **Note**: The storage productName uses the abbreviation `Az DB for PostgreSQL` — not the full `Azure Database for PostgreSQL`.
