---
serviceName: Azure Cosmos DB
category: databases
aliases: [CosmosDB, DocumentDB, Multi-model DB]
billingConsiderations: [Reserved Instances]
primaryCost: "Provisioned throughput (RU/s per-hour) + storage"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Cosmos DB

> **Trap**: The storage meter is `'Data Stored'` (not `'1 GB Data Stored'`). You also need `-ProductName 'Azure Cosmos DB'` and `-SkuName 'RUs'` to filter to the transactional storage meter and avoid free-tier/multi-master variants.

> **Trap (PITR vs Backup vault)**: Cosmos DB native PITR (`productName: Azure Cosmos DB - PITR`) is billed under `serviceName: Azure Cosmos DB` (Databases) at ~9× the per-GB rate of Azure Backup vault storage (`serviceName: Backup`, Storage). If users say "Azure Backup for Cosmos DB", clarify whether they mean native continuous backup (PITR) or vault-based backup (see `storage/backup.md`).
> **Agent instruction**: "continuous backup tier", "PITR", "point-in-time restore", "30-day backup" → native Cosmos DB PITR. "Azure Backup vault", "Recovery Services Vault", "backup vault storage" → vault-based backup. If genuinely ambiguous, stop and ask.

## Query Pattern

### Provisioned throughput (e.g., 400 RU/s → Quantity: 4)

ServiceName: Azure Cosmos DB
MeterName: 100 RU/s
SkuName: RUs
Quantity: 4

### Autoscale provisioned throughput (e.g., 10,000 max RU/s → Quantity: 100)

ServiceName: Azure Cosmos DB
ProductName: Azure Cosmos DB autoscale
MeterName: AP1 100 RUs
SkuName: AP1
Quantity: 100

### Storage (transactional)

ServiceName: Azure Cosmos DB
ProductName: Azure Cosmos DB
MeterName: Data Stored
SkuName: RUs

## Key Fields

| Parameter     | How to determine         | Example values                                                                 |
| ------------- | ------------------------ | ------------------------------------------------------------------------------ |
| `serviceName` | Always `Azure Cosmos DB` | `Azure Cosmos DB`                                                              |
| `productName` | Pricing model variant    | `Azure Cosmos DB`, `Azure Cosmos DB autoscale`, `Azure Cosmos DB serverless`, `Azure Cosmos DB - PITR` |
| `skuName`     | Throughput or add-on     | `RUs`, `mRUs`, `AP1`, `Backup`, `Standard`                                     |
| `meterName`   | Resource being metered   | `100 RU/s`, `Data Stored`, `1M RUs`, `Standard Data Stored`, `Backup Data Stored` |

## Meter Names

| Meter                         | skuName | productName                         | unitOfMeasure | Notes                                  |
| ----------------------------- | ------- | ----------------------------------- | ------------- | -------------------------------------- |
| `100 RU/s`                    | `RUs`   | `Azure Cosmos DB`                   | `1/Hour`      | Use `-Quantity N` where N = RU/s ÷ 100 |
| `100 Multi-master RU/s`       | `mRUs`  | `Azure Cosmos DB`                   | `1/Hour`      | For multi-region writes                |
| `Data Stored`                 | `RUs`   | `Azure Cosmos DB`                   | `1 GB/Month`  | Transactional storage                  |
| `1M RUs`                      | `RUs`   | `Azure Cosmos DB serverless`        | `1M`          | Serverless consumed RUs                |
| `AP1 100 RUs`                 | `AP1`   | `Azure Cosmos DB autoscale`         | `1/Hour`      | Autoscale RU unit                      |
| `Standard Data Stored`        | `Standard` | `Azure Cosmos DB Analytics Storage` | `1 GB/Month` | Analytical store                       |
| `Backup Data Stored`          | `Standard` | `Azure Cosmos DB Snapshot`       | `1 GB/Month`  | Periodic backup storage                |
| `Cont 30D Bckp Continuous Backup` | `Backup` | `Azure Cosmos DB - PITR`       | `1 GB`        | Native continuous backup               |

## Cost Formula

```
Monthly Throughput = retailPrice_per_100RUs × (provisionedRUs / 100) × 730 hours
Monthly Storage    = storage_retailPrice × sizeInGB
Total              = Throughput + Storage
```

Free-tier confirmed (user explicitly states free-tier-eligible account):

```
Monthly Throughput = retailPrice_per_100RUs × max(0, provisionedRUs - 1000) / 100 × 730 hours
Monthly Storage    = storage_retailPrice × max(0, sizeInGB - 25)
Total              = Throughput + Storage
```

## Notes

- Free tier available (1000 RU/s + 25 GB free, one account per subscription)
- **Free tier guidance**: Do NOT deduct the free tier (1000 RU/s + 25 GB) from estimates unless the user explicitly confirms they are using a free-tier-eligible account. Production workloads typically do not use the free tier (only one free-tier account per subscription). Always ask the user if uncertain.
- Serverless pricing: per-RU consumed (different meter: `1M RUs` under productName `Azure Cosmos DB serverless`) plus transactional storage through the base `Azure Cosmos DB` product's `Data Stored` meter.
- Multi-region: multiply provisioned throughput and transactional storage by number of regions; serverless accounts are single-region.
- The storage query returns multiple skuName variants (`RUs`, `mRUs`, `RUm`, `Free Tier`); filter to `RUs` for standard provisioned
- **Multi-region write (multi-master) costs ~2× single-region**: The `100 Multi-master RU/s` meter (skuName `mRUs`) is approximately double the price of the standard `100 RU/s` meter (skuName `RUs`). Always inform users about this multiplier when they request multi-region writes. For cost comparison, query both meters and show the per-region price difference.
- **Autoscale provisioned throughput**: The API has a separate product (`Azure Cosmos DB autoscale`) with `AP1`-`AP4` 100-RU meters and entry-price meters. Do NOT query the standard `100 RU/s` meter and manually multiply by 1.5. Billing is based on the highest autoscaled RU/s used each hour; if hourly peaks are unknown, use `Tmax` as an upper-bound estimate.
- **MongoDB vCore**: Cosmos DB for MongoDB vCore uses productName `Azure DocumentDB` with vCore-based billing (coordinator + worker nodes, per-vCore hourly). Do not use RU/s queries for vCore clusters.
- **Backup costs (Databases, not Storage)**: Native continuous backup (`productName: Azure Cosmos DB - PITR`) and periodic backups (`productName: Azure Cosmos DB Snapshot`) are billed per-GB under `serviceName: Azure Cosmos DB`. 7-day continuous is zero-price; 30-day, restore, on-demand, and periodic redundancy meters are charged. Do NOT confuse with Azure Backup vault storage (`serviceName: Backup`).
- **Add-on products**: Dedicated Gateway, Garnet Cache, Materialized Views, Analytics Storage, Graph API compute, and `Cosmos DB Compute Attached SSD Disk` have separate productNames under the same serviceName; query each individually.
- **PE sub-resources** (never-assume): `Sql`, `MongoDB`, `Cassandra`, `Gremlin`, `Table`. Conditional: `SqlDedicated` (dedicated gateway), `Analytical` (analytical store managed PE)

## Reserved Instance Pricing

ServiceName: Azure Cosmos DB
MeterName: 100 RU/s
PriceType: Reservation
Region: Global

> **Trap (RI region)**: RU-based Cosmos DB RI uses `Region: Global`; regional queries return zero results. MongoDB vCore RI (`productName: Azure DocumentDB Reservations`) uses standard regional pricing instead.
