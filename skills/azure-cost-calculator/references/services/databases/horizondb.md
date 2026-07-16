---
serviceName: Azure HorizonDB
category: databases
aliases: [Horizon DB, Distributed PostgreSQL]
apiServiceName: Azure Database for PostgreSQL
primaryCost: "vCore hourly rate × 730 + storage per-GB/month + billable backup over free grant"
privateEndpoint: true
---

# Azure HorizonDB

> **Trap**: The API `serviceName` `Azure Database for PostgreSQL` is shared with Flexible Server, Cosmos DB for PostgreSQL, and other products. Always filter by `productName` to isolate HorizonDB meters. Unfiltered queries return mixed results from all product families.

> **Trap (productName casing)**: Storage productName uses lowercase 's' (`Azure HorizonDB storage`) while Backup uses title case (`Azure HorizonDB Backup Storage`). Compute uses a different prefix pattern (`Azure Database for PostgreSQL HorizonDB Compute`). Use exact casing from the API.

## Query Pattern

### Compute (4 vCores)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL HorizonDB Compute
SkuName: 1 vCore
MeterName: 1 vCore
InstanceCount: 4 # vCore count

### Storage (100 GB)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure HorizonDB storage
SkuName: HorizonDB storage
MeterName: HorizonDB storage Data Stored
Quantity: 100 # storage size in GB

### Backup storage (50 GB beyond free grant)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure HorizonDB Backup Storage
SkuName: HorizonDB Backup Storage
MeterName: HorizonDB Backup Storage Data Stored
Quantity: 50 # backup GB beyond included grant

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
| `1 vCore Free Tier`                    | `1 Hour`      | API-only zero-price meter; use only with confirmed entitlement |
| `HorizonDB storage Data Stored`        | `1 GB/Month`  | Data storage per GB            |
| `HorizonDB Backup Storage Data Stored` | `1 GB/Month`  | Backup storage per GB          |
| `Backup 0 meter Data Stored`           | `1 GB/Month`  | Included backup grant meter    |

## Cost Formula

```
Monthly Compute = compute_retailPrice × 730 × vCoreCount
Monthly Storage = storage_retailPrice × sizeGB
Billable Backup GB = max(0, backupGB - clusterSizeGB)
Monthly Backup  = backup_retailPrice × billableBackupGB
Total = Compute + Storage + Backup
```

## Notes

- Azure HorizonDB is in **public preview**; Retail Prices API meters may change before GA
- Microsoft Learn currently lists Central US, East US, West US 2, West US 3, Sweden Central, and Australia East. Verify target region support before estimating
- Storage productName uses lowercase 's' (`Azure HorizonDB storage`); use exact casing
- Shares `serviceName` with PostgreSQL Flexible Server (see `databases/database-for-postgresql.md`)
- Storage, vCore count, replica count, and billable backup beyond the included grant are never-assume parameters: always ask the user
- Backup storage equal to the cluster size has no extra charge; use the paid backup meter only for excess backup consumption
- API exposes `1 vCore Free Tier`, but Microsoft Learn and the pricing page do not define a free compute tier. Use paid compute unless the user confirms entitlement
- Private Link is supported; virtual network injection is not. Price private endpoints via `networking/private-link.md`
- AI model usage is billed at Microsoft Foundry rates if enabled
- No Reserved Instance pricing available in the API
