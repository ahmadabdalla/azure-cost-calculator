---
serviceName: Azure HorizonDB
category: databases
aliases: [Horizon DB, Distributed PostgreSQL]
apiServiceName: Azure Database for PostgreSQL
primaryCost: "Storage per-GB/month + backup storage per-GB/month"
---

# Azure HorizonDB

> **Trap**: The API `serviceName` `Azure Database for PostgreSQL` is shared with Flexible Server, Cosmos DB for PostgreSQL, and other products. Always filter by `productName` to isolate HorizonDB meters — unfiltered queries return mixed results from all product families.

> **Trap (no compute meters)**: HorizonDB currently has no compute meters in the API (preview). Only storage and backup are billable. Do not report zero compute cost — inform the user that compute pricing is not yet available.

## Query Pattern

### Storage cost (100 GB)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure HorizonDB storage
SkuName: HorizonDB storage
MeterName: HorizonDB storage Data Stored
Quantity: 100 # storage size in GB

### Backup storage cost (50 GB)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure HorizonDB Backup Storage
SkuName: HorizonDB Backup Storage
MeterName: HorizonDB Backup Storage Data Stored
Quantity: 50 # backup size in GB

## Key Fields

| Parameter     | How to determine                     | Example values                                                         |
| ------------- | ------------------------------------ | ---------------------------------------------------------------------- |
| `productName` | Storage vs backup (exact case match) | `Azure HorizonDB storage`, `Azure HorizonDB Backup Storage`           |
| `skuName`     | Matches product type                 | `HorizonDB storage`, `HorizonDB Backup Storage`                       |
| `meterName`   | Data Stored meter for each product   | `HorizonDB storage Data Stored`, `HorizonDB Backup Storage Data Stored` |

## Meter Names

| Meter                                     | unitOfMeasure | Notes                |
| ----------------------------------------- | ------------- | -------------------- |
| `HorizonDB storage Data Stored`           | `1 GB/Month`  | Data storage per GB  |
| `HorizonDB Backup Storage Data Stored`    | `1 GB/Month`  | Backup storage per GB |

## Cost Formula

```
Monthly Storage = storage_retailPrice × sizeGB
Monthly Backup  = backup_retailPrice × backupGB
Total = Storage + Backup
```

## Notes

- HorizonDB is in preview — pricing may change before GA
- Compute pricing is not yet available in the API; estimates cover storage and backup only
- Storage productName uses lowercase 's' (`Azure HorizonDB storage`) — use exact casing
- Shares `serviceName` with PostgreSQL Flexible Server — see `databases/database-for-postgresql.md`
- Storage size is a never-assume parameter: always ask the user for provisioned size in GB
- Backup storage billing details (free grant, retention policy) are not yet documented
- OrionDB Compute meters exist under the same API serviceName but are a separate product — not included here
