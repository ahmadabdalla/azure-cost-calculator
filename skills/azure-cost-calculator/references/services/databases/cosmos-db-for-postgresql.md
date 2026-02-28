---
serviceName: Azure Cosmos DB for PostgreSQL
category: databases
aliases: [Cosmos DB PostgreSQL, Citus, PostgreSQL Hyperscale, Cosmos DB for Postgres]
billingConsiderations: [Reserved Instances]
apiServiceName: Azure Database for PostgreSQL
primaryCost: "Coordinator + worker node vCore hourly rate × 730 + storage per-GiB/month"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Cosmos DB for PostgreSQL

> **Warning**: This service is on a retirement path. Microsoft recommends migrating to Azure Database for PostgreSQL Flexible Server with Elastic Clusters (Citus extension).

> **Trap (shared serviceName)**: The API `serviceName` is `Azure Database for PostgreSQL`, shared with Flexible Server. Always filter by `productName` containing `Cosmos DB for PostgreSQL` to isolate this service's meters.

## Query Pattern

### Coordinator node compute (e.g., 8 vCores)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure Cosmos DB for PostgreSQL Compute- Coordinator Node
SkuName: vCore
MeterName: vCore

### Worker node compute (e.g., 4 vCores × 3 workers)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure Cosmos DB for PostgreSQL Compute- Worker Node
SkuName: vCore
MeterName: vCore
InstanceCount: 3 # number of worker nodes

### General Purpose storage (e.g., 512 GiB)

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure Cosmos DB for PostgreSQL General Purpose Storage
SkuName: General Purpose
MeterName: General Purpose Data Stored
Quantity: 512 # storage size in GiB per node

## Key Fields

| Parameter     | How to determine                  | Example values                                              |
| ------------- | --------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always the shared API name        | `Azure Database for PostgreSQL`                             |
| `productName` | Node role or storage type         | See Product Names table below                               |
| `skuName`     | `vCore` for compute, tier for storage | `vCore`, `1 vCore`, `General Purpose`                   |
| `meterName`   | `vCore` for compute, named for storage | `vCore`, `General Purpose Data Stored`                 |

## Meter Names

| Meter                        | skuName           | productName (suffix)     | unitOfMeasure | Notes                        |
| ---------------------------- | ----------------- | ------------------------ | ------------- | ---------------------------- |
| `vCore`                      | `vCore`           | `Compute- Coordinator Node` | `1 Hour`   | Per-vCore rate; multiply by count |
| `vCore`                      | `vCore`           | `Compute- Worker Node`   | `1 Hour`      | Per-vCore rate; multiply by count |
| `vCore`                      | `1 vCore` – `8m vCore` | `Compute- Burstable` | `1 Hour`  | Fixed SKU; single-node only  |
| `General Purpose Data Stored`| `General Purpose` | `General Purpose Storage`| `1 GiB/Month` | GP SSD storage per node      |
| `Backup LRS/GRS Data Stored` | `Backup LRS/GRS`  | `Backup Storage`         | `1 GiB/Month` | Currently free               |

## Cost Formula

```
Coordinator Compute = coordinator_retailPrice × coordinatorVCores × 730
Worker Compute      = worker_retailPrice × workerVCores × workerNodeCount × 730
Storage             = storage_retailPrice × storageGiB × nodeCount
Total               = Coordinator Compute + Worker Compute + Storage
```

## Notes

- Free tier: single-node cluster at no cost (`skuName: Free`). Only deduct when user confirms free-tier usage
- Burstable: dev/test single-node only (1–2 vCores, plus memory-optimized 2m–8m vCores), does NOT support RI
- Multi-node: 1 coordinator (query routing) + N workers (sharding/scale-out, min 2). Scale horizontally by adding workers
- Worker vCores: 4, 8, 16, 32, 64, 96, 104; Coordinator vCores: 4, 8, 16, 32, 64, 96
- Backup storage is currently free (up to 100% of provisioned storage)
- High Availability doubles compute cost — no separate meter; multiply compute by 2
- Shares `serviceName` with Azure Database for PostgreSQL Flexible Server — see `database-for-postgresql.md`

## Reserved Instance Pricing

ServiceName: Azure Database for PostgreSQL <!-- cross-service -->
ProductName: Azure Cosmos DB for PostgreSQL Compute- Coordinator Node
SkuName: vCore
MeterName: vCore
PriceType: Reservation

> **Trap (RI MonthlyCost)**: The script's `MonthlyCost` is wrong for RI — it multiplies by 730. Calculate: `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year). RI is per-vCore; multiply by total vCore count (double if HA enabled).
> For Worker node RI, use the same filters but set `ProductName` to `Azure Cosmos DB for PostgreSQL Compute- Worker Node`.

## Product Names

| Config              | productName                                                    |
| ------------------- | -------------------------------------------------------------- |
| Coordinator compute | `Azure Cosmos DB for PostgreSQL Compute- Coordinator Node`     |
| Worker compute      | `Azure Cosmos DB for PostgreSQL Compute- Worker Node`          |
| Burstable compute   | `Azure Cosmos DB for PostgreSQL Compute- Burstable`            |
| GP Storage          | `Azure Cosmos DB for PostgreSQL General Purpose Storage`       |
| Backup Storage      | `Azure Cosmos DB for PostgreSQL Backup Storage`                |
