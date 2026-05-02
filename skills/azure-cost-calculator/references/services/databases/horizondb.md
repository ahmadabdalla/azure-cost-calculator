---
serviceName: Azure HorizonDB
category: databases
aliases: [Horizon DB, Distributed PostgreSQL]
apiServiceName: Azure Database for PostgreSQL
primaryCost: "vCore hourly rate × 730 + storage per-GB/month + backup per-GB/month"
---

# Azure HorizonDB

> **Trap**: The API `serviceName` `Azure Database for PostgreSQL` is shared with Flexible Server, Cosmos DB for PostgreSQL, and other products. Always filter by `productName` to isolate HorizonDB meters. Unfiltered queries return mixed results from all product families.

> **Trap (productName casing)**: Storage productName uses lowercase 's' (`Azure HorizonDB storage`) while Backup and Compute use title case. Use exact casing from the API.

## Query Pattern

### Compute (4 vCores)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure Database for PostgreSQL HorizonDB Compute
SkuName: 1 vCore
MeterName: 1 vCore
InstanceCount: 4 # vCore count

### Storage (100 GB)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure HorizonDB storage
SkuName: HorizonDB storage
MeterName: HorizonDB storage Data Stored
Quantity: 100 # storage size in GB

### Backup storage (50 GB)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure HorizonDB Backup Storage
SkuName: HorizonDB Backup Storage
MeterName: HorizonDB Backup Storage Data Stored
Quantity: 50 # backup size in GB

## Key Fields

| Parameter     | How to determine                        | Example values                                                                                          |
| ------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `productName` | Compute vs storage vs backup            | `Azure Database for PostgreSQL HorizonDB Compute`, `Azure HorizonDB storage`, `Azure HorizonDB Backup Storage` |
| `skuName`     | `1 vCore` for compute; product name for storage/backup | `1 vCore`, `HorizonDB storage`, `HorizonDB Backup Storage`                                              |
| `meterName`   | `1 vCore` for compute; Data Stored for storage/backup  | `1 vCore`, `HorizonDB storage Data Stored`, `HorizonDB Backup Storage Data Stored`                     |

## Meter Names

| Meter                                  | unitOfMeasure | Notes                          |
| -------------------------------------- | ------------- | ------------------------------ |
| `1 vCore`                              | `1 Hour`      | Per-vCore compute; use InstanceCount for sizing |
| `HorizonDB storage Data Stored`        | `1 GB/Month`  | Data storage per GB            |
| `HorizonDB Backup Storage Data Stored` | `1 GB/Month`  | Backup storage per GB          |

## Cost Formula

```
Monthly Compute = compute_retailPrice × 730 × vCoreCount
Monthly Storage = storage_retailPrice × sizeGB
Monthly Backup  = backup_retailPrice × backupGB
Total = Compute + Storage + Backup
```

## Notes

- HorizonDB is in preview; pricing may change before GA
- Storage productName uses lowercase 's' (`Azure HorizonDB storage`); use exact casing
- Shares `serviceName` with PostgreSQL Flexible Server (see `databases/database-for-postgresql.md`)
- Storage and vCore count are never-assume parameters: always ask the user
- No Reserved Instance pricing available in the API
