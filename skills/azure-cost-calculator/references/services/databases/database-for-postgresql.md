---
serviceName: Azure Database for PostgreSQL
category: databases
aliases: [PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server]
billingConsiderations: [Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure Database for PostgreSQL Flexible Server

> **Trap (productName inconsistency)**: `productName` has inconsistent naming across series. Some use `General Purpose - Ddsv5` (with hyphen) while others use `General Purpose Dadsv5` (no hyphen). The Esv3 product uses `Az DB for PGSQL`, storage uses `Az DB for PostgreSQL`, all others use `Azure Database for PostgreSQL`. Always use the exact string from discovery.

> **Trap (v6 meterName)**: Newer v6 and Confidential Compute series use `MeterName: 1 vCore` and `SkuName: 1 vCore` instead of `MeterName: vCore` with `SkuName: N vCore`. Queries using `MeterName: vCore` will miss v6 series. For v6, query with `SkuName: 1 vCore` and multiply the per-vCore rate by the desired vCore count.

## Query Pattern

### Compute (General Purpose, Ddsv5 series, 4 vCores)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv5 Series Compute
SkuName: vCore
MeterName: vCore
InstanceCount: 4 # vCore count

### Compute (General Purpose, Ddsv6 series, 4 vCores)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL Flexible Server General Purpose Ddsv6 Series Compute
SkuName: 1 vCore
MeterName: 1 vCore
InstanceCount: 4 # vCore count

### Storage (100 GB)

ServiceName: Azure Database for PostgreSQL
ProductName: Az DB for PostgreSQL Flexible Server Storage
SkuName: Storage
MeterName: Storage Data Stored
Quantity: 100 # storage size in GB

## Key Fields

| Parameter     | How to determine                   | Example values                                              |
| ------------- | ---------------------------------- | ----------------------------------------------------------- |
| `productName` | Tier + series (exact match)        | See Product Names table below                               |
| `skuName`     | v4/v5: `'N vCore'`; v6: `'1 vCore'` | `'4 vCore'`, `'1 vCore'`, `'vCore'`                        |
| `meterName`   | v4/v5: `'vCore'`; v6: `'1 vCore'`  | `'vCore'`, `'1 vCore'`, `'Storage Data Stored'`             |

## Meter Names

| Meter                            | skuName              | unitOfMeasure | Notes                                       |
| -------------------------------- | -------------------- | ------------- | ------------------------------------------- |
| `vCore`                          | `N vCore` or `vCore` | `1 Hour`      | v4/v5 series; use InstanceCount for sizing  |
| `1 vCore`                        | `1 vCore`            | `1 Hour`      | v6/Confidential series; per-vCore rate      |
| `Storage Data Stored`            | `Storage`            | `1 GB/Month`  | Standard LRS storage                        |
| `Backup Storage LRS Data Stored` | `Backup Storage LRS` | `1 GB/Month`  | Backup beyond free grant                    |
| `IOPS Scaling Provisioned IOPS`  | `IOPS Scaling`       | `1/Month`     | Per additional provisioned IOP              |

## Cost Formula

```
Monthly Compute = compute_retailPrice × 730 × vCoreCount
Monthly Storage = storage_retailPrice × sizeGB
Total = Compute + Storage (+ optional IOPS + Backup)
```

## Notes

- Burstable: dev/test workloads, does NOT support RI. Uses fixed SKU names (B1MS, B2S, B4ms, etc.)
- GP: production workloads, supports RI. Per-vCore pricing with InstanceCount
- MO: high-memory workloads, supports RI. Same per-vCore pattern as GP
- Mdsv2: ultra-high-memory workloads. Uses fixed VM-size SKUs (M128dms_v2, etc.), no RI
- High Availability doubles compute cost (deploys a standby replica); no separate HA meter
- Backup storage: first backup equal to DB size is free; excess charged per-GB/month (LRS only)
- Storage options: Standard (GB), Premium Managed Disk V2 (GiB + IOPS + throughput), Ultra Disk (GB + IOPS + throughput)
- Single Server is deprecated; all new deployments use Flexible Server
- Cosmos DB for PostgreSQL and HorizonDB meters share this serviceName; filter by productName

## Product Names

| Config              | productName                                                                            |
| ------------------- | -------------------------------------------------------------------------------------- |
| GP, Ddsv5           | `Azure Database for PostgreSQL Flexible Server General Purpose - Ddsv5 Series Compute` |
| GP, Dadsv5          | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv5 Series Compute`  |
| GP, Ddsv6           | `Azure Database for PostgreSQL Flexible Server General Purpose Ddsv6 Series Compute`   |
| GP, Dadsv6          | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv6 Series Compute`  |
| GP, Dsv6            | `Azure Database for PostgreSQL Flexible Server General Purpose Dsv6 Series Compute`    |
| GP, Dasv6           | `Azure Database for PostgreSQL Flexible Server General Purpose Dasv6 Series Compute`   |
| MO, Edsv5           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv5 Series Compute`  |
| MO, Eadsv5          | `Azure Database for PostgreSQL Flexible Server Memory Optimized Eadsv5 Series Compute` |
| MO, Edsv6           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv6 Series Compute`  |
| MO, Eadsv6          | `Azure Database for PostgreSQL Flexible Server Memory Optimized Eadsv6 Series Compute` |
| MO, Esv6            | `Azure Database for PostgreSQL Flexible Server Memory Optimized Esv6 Series Compute`   |
| MO, Easv6           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Easv6 Series Compute`  |
| Mdsv2               | `Azure Database for PostgreSQL Flexible Server Mdsv2 Series Compute`                   |
| Confidential, DC v6 | `Azure Database for PostgreSQL Flexible Server Confidential Compute DCadsv6 Series Compute` |
| Burstable, BS       | `Azure Database for PostgreSQL Flexible Server Burstable BS Series Compute`            |
| Storage             | `Az DB for PostgreSQL Flexible Server Storage`                                         |
| Backup              | `Azure Database for PostgreSQL Flexible Server Backup Storage`                         |
