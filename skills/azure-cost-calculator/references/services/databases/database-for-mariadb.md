---
serviceName: Azure Database for MariaDB
category: databases
aliases: [MariaDB, Azure MariaDB]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure Database for MariaDB

> **Trap**: Queries without a region filter return paginated rows across all regions; a single-region query returns ~30 rows covering all unique meter types. Always filter by `ProductName` to target one tier and generation.

> **Trap**: `Azure Database for MariaDB Compute Reservation` is a zero-price `Consumption` artifact with empty `armRegionName`; it is not usable reservation pricing. Exclude it with explicit real `ProductName` filters.

> **Warning**: Azure Database for MariaDB was **retired on 19 September 2025**. Do not recommend for new workloads. Use this reference only for legacy existing-resource estimates where Retail API meters are still returned. Direct new or migration estimates to Azure Database for MySQL (`database-for-mysql.md`).

## Query Pattern

### Compute: General Purpose Gen5 (4 vCores)

ServiceName: Azure Database for MariaDB
ProductName: Azure Database for MariaDB Single Server General Purpose - Compute Gen5
SkuName: vCore
MeterName: vCore
InstanceCount: 4 # vCore count

### Storage (100 GB)

ServiceName: Azure Database for MariaDB
ProductName: Azure Database for MariaDB Single Server General Purpose - Storage
SkuName: General Purpose
MeterName: General Purpose Data Stored
Quantity: 100 # storage size in GB

### Compute: Memory Optimized Gen5 (8 vCores)

ServiceName: Azure Database for MariaDB
ProductName: Azure Database for MariaDB Single Server Memory Optimized - Compute Gen5
SkuName: vCore
MeterName: vCore
InstanceCount: 8 # vCore count

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `productName` | Tier + generation (exact match) | See Product Names below |
| `skuName` | Per-vCore: `'vCore'`; Basic: `'1 vCore'`, `'2 vCore'` | `'vCore'`, `'2 vCore'` |
| `meterName` | Usually `'vCore'` for compute; Basic 2-vCore uses `'2 vCore'`; tier-specific for storage | `'vCore'`, `'2 vCore'` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `vCore` | `vCore` | `1 Hour` | Per-vCore rate for GP/MO Gen5; use InstanceCount |
| `vCore` | `N vCore` | `1 Hour` | Total rate for N vCores in GP Gen4/Gen5 and MO Gen5 |
| `2 vCore` | `2 vCore` | `1 Hour` | Total rate for Basic Gen4/Gen5 2-vCore SKU only |
| `Basic Data Stored` | `Basic` | `1 GB/Month` | Basic tier data storage |
| `General Purpose Data Stored` | `General Purpose` | `1 GB/Month` | GP/MO data storage |
| `Backup LRS Data Stored` | `Backup LRS` | `1 GB/Month` | Locally-redundant backup storage |
| `Backup GRS Data Stored` | `Backup GRS` | `1 GB/Month` | Geo-redundant backup storage |

## Cost Formula

```
Compute (per-vCore) = compute_retailPrice × 730 × vCoreCount
Compute (fixed N-vCore SKU) = compute_retailPrice × 730
Storage = storage_retailPrice × sizeGB
Backup (excess) = backup_retailPrice × max(0, backupGB - provisionedStorageGB)
Total = Compute + Storage + Backup (excess)
```

## Notes

- **Retired**: Service reached end-of-life on 19 September 2025; migrate to Azure Database for MySQL (`database-for-mysql.md`)
- Basic: dev/test, 1–2 vCores only, no Private Endpoint support
- GP: production workloads, Gen5 up to 64 vCores
- MO: high-memory workloads, Gen5 up to 32 vCores
- Reserved Instances: not available; `priceType=Reservation` returns no meters
- GP/MO Gen5 `skuName='vCore'` is per-vCore for `InstanceCount`; `N vCore` SKUs are fixed total rates
- Basic tier storage uses `Basic Data Stored`, not the General Purpose storage product
- Backup: first backup equal to provisioned storage is free; excess charged per-GB/month (LRS or GRS)
- Read replicas (GP/MO only): billed at full compute + storage rates
- Private Endpoint supported for GP and MO tiers only (not Basic)
- Gen4 hardware is deprecated; Gen5 recommended for all tiers
- Additional storage products (Large-Scale Storage, Perf Optimized Storage) exist in some regions at different price points

## Product Names

| Config | productName |
| --- | --- |
| Basic, Gen5 | `Azure Database for MariaDB Single Server Basic - Compute Gen5` |
| Basic, Gen4 (deprecated) | `Azure Database for MariaDB Single Server Basic - Compute Gen4` |
| GP, Gen5 | `Azure Database for MariaDB Single Server General Purpose - Compute Gen5` |
| GP, Gen4 (deprecated) | `Azure Database for MariaDB Single Server General Purpose - Compute Gen4` |
| MO, Gen5 | `Azure Database for MariaDB Single Server Memory Optimized - Compute Gen5` |
| Basic Storage | `Azure Database for MariaDB Single Server Basic - Storage` |
| GP/MO Storage | `Azure Database for MariaDB Single Server General Purpose - Storage` |
| GP Large-Scale Storage | `Azure Database for MariaDB General Purpose - Large-Scale Storage` |
| Perf Optimized Storage | `Azure Database for MariaDB Perf Optimized - Storage` |
| Backup | `Azure Database for MariaDB Single Server - Backup Storage` |
