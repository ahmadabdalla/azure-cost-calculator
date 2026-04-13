---
serviceName: Azure Database for MariaDB
category: databases
aliases: [MariaDB, Azure MariaDB]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure Database for MariaDB

> **Trap**: Unfiltered queries return ~30 meters across Basic, General Purpose, and Memory Optimized tiers plus multiple storage products. Always filter by `ProductName` to target one tier and generation.

> **Note**: This service is announced for retirement (September 2025). Pricing data remains active in the API. Microsoft recommends migrating to Azure Database for MySQL.

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
| `meterName` | Always `'vCore'` for compute; tier-specific for storage | `'vCore'`, `'General Purpose Data Stored'` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `vCore` | `vCore` | `1 Hour` | Per-vCore rate for GP/MO Gen5; use InstanceCount |
| `vCore` | `N vCore` | `1 Hour` | Total rate for N vCores (Basic, GP Gen4/Gen5) |
| `General Purpose Data Stored` | `General Purpose` | `1 GB/Month` | GP/MO data storage |
| `Backup LRS Data Stored` | `Backup LRS` | `1 GB/Month` | Locally-redundant backup storage |
| `Backup GRS Data Stored` | `Backup GRS` | `1 GB/Month` | Geo-redundant backup storage |

## Cost Formula

```
Compute (per-vCore) = compute_retailPrice × 730 × vCoreCount
Storage = storage_retailPrice × sizeGB
Backup (excess) = backup_retailPrice × max(0, backupGB - provisionedStorageGB)
Total = Compute + Storage + Backup (excess)
```

## Notes

- **Retiring**: Service end-of-life September 2025; migrate to Azure Database for MySQL
- Basic: dev/test, 1–2 vCores only, no Private Endpoint support
- GP: production workloads, Gen5 up to 64 vCores
- MO: high-memory workloads, Gen5 up to 32 vCores
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
| Backup | `Azure Database for MariaDB Single Server - Backup Storage` |
