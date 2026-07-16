---
serviceName: SQL Database
category: databases
aliases: [Azure SQL, SQL DB]
billingConsiderations: [Azure Hybrid Benefit, Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage/backup per-GB/month"
hasFreeGrant: true
privateEndpoint: true
---

# Azure SQL Database

> **Trap (inflated totals)**: Omitting `SkuName` returns all vCore sizes summed. Filter `ProductName` always, plus `SkuName`/`MeterName` for multi-meter products; single-meter products like SQL License need only `ProductName`. The service has 39 products spanning vCore, DTU, Serverless, Elastic Pool, storage, backup, and add-ons.

> **Trap (DTU billing)**: DTU tiers (Basic/Standard/Premium) use `unitOfMeasure: 1/Day`. The script auto-multiplies by 30 for these meters, so `MonthlyCost` is already the monthly cost.

> **Trap (Zone Redundancy)**: GP zone-redundant deployments have separate compute meters (`Zone Redundancy vCore`) and storage meters (`General Purpose Zone Redundancy Data Stored` at ~2× standard rate). The ZR compute meter is an additive hourly surcharge. BC includes zone-redundant HA in base price (no separate ZR meter).

## Query Pattern

### vCore compute (e.g., 2 vCore GP; swap productName for Business Critical)
ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - Compute Gen5
SkuName: 2 vCore
MeterName: vCore

### Storage (use Quantity for provisioned GB)
ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - Storage
MeterName: General Purpose Data Stored
Quantity: 256

### Backup storage (PITR over included allowance; swap productName for LTR)
ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool PITR Backup Storage
SkuName: Backup LRS
MeterName: LRS Data Stored
Quantity: 100

> For LTR: use `ProductName: SQL Database - LTR Backup Storage` and `MeterName: Backup LRS Data Stored`.

## Key Fields

| Parameter     | How to determine                                  | Example values                             |
| ------------- | ------------------------------------------------- | ------------------------------------------ |
| `serviceName` | Always `SQL Database`                             | `SQL Database`                             |
| `productName` | Deployment type + tier + generation               | See Product Names section below            |
| `skuName`     | vCore count, DTU tier, or backup redundancy       | `1 vCore`, `2 vCore`, `S0`, `Backup LRS`   |
| `meterName`   | Compute, storage, backup, license, or I/O meter   | `vCore`, `General Purpose Data Stored`     |

## Meter Names

| Meter                                      | unitOfMeasure | Notes                                  |
| ------------------------------------------ | ------------- | -------------------------------------- |
| `vCore`                                    | `1 Hour`      | Compute meter for vCore tiers          |
| `Zone Redundancy vCore`                    | `1 Hour`      | GP zone-redundancy compute surcharge   |
| `General Purpose Data Stored`              | `1 GB/Month`  | Storage for General Purpose tier       |
| `General Purpose Zone Redundancy Data Stored` | `1 GB/Month` | ZR storage for General Purpose tier    |
| `Business Critical Data Stored`            | `1 GB/Month`  | Storage for Business Critical tier     |
| `Hyperscale Data Stored`                   | `1 GB/Month`  | Storage for Hyperscale tier            |
| `General Purpose IO Rate Operations`       | `1M`          | Optional GP I/O operations             |
| `General Purpose Zone Redundancy IO Rate Operations` | `1M` | Optional GP ZR I/O operations          |
| `Business Critical IO Rate Operations`     | `1M`          | Optional BC I/O operations             |
| `Hyperscale IO Rate Operations`            | `1M`          | Optional Hyperscale I/O operations     |
| `LRS Data Stored`                          | `1 GB/Month`  | PITR backup over included allowance    |
| `Backup LRS Data Stored`                   | `1 GB/Month`  | LTR backup storage                     |

## Cost Formula

```
Monthly Compute = compute_retailPrice × 730
Monthly Storage = storage_retailPrice × sizeInGB
Monthly IO = (ioOperations / 1,000,000) × io_retailPrice
Monthly Backup = backup_retailPrice × billableBackupGB
Total = Compute + Storage + IO + Backup
Zone-Redundant GP = (base_retailPrice + zr_retailPrice) × 730 + zr_storage_retailPrice × sizeInGB
```

## Notes

- **Storage**: vCore GP, BC, and Hyperscale storage is billed separately for configured max size. Standard/Premium DTU storage products exist for storage beyond bundled tier limits.
- **Backups**: PITR backup storage up to the database/max data size is included; bill overage with `SQL Database Single/Elastic Pool PITR Backup Storage`. LTR is billed separately from the first retained GB with `SQL Database - LTR Backup Storage`.
- **DTU model**: Basic (5 DTU), Standard (S0-S12), Premium (P1-P15), and elastic pools use `1/Day` DTU/eDTU billing.
- **Free offer**: Up to 10 General Purpose databases per subscription can use the free offer (100,000 vCore seconds, 32 GB data, 32 GB backup per month). Do not deduct unless the user explicitly selected the free offer.
- **Tier guide**: GP for standard workloads; BC includes zone-redundant HA in base price; Hyperscale for large databases with separate storage and optional named replicas.
- **Serverless**: Use serverless compute products for auto-pause/autoscale workloads; filter `MeterName: vCore` because zero-price `* vCore - Free` rows also exist.
- **Capacity**: vCore count determines compute capacity; double vCores for ~2× throughput.

## Reserved Instance Pricing

### RI compute (SkuName is per-vCore; swap productName for BC/Hyperscale)
ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - Compute Gen5
SkuName: vCore
MeterName: vCore
PriceType: Reservation

> **Trap (RI skuName)**: RI `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero results. Calculate: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y). RI prices are already license-excluded; do NOT subtract SQL License. For GP zone redundancy RI, use `SkuName: vCore ZR Zone Redundancy` and `MeterName: Zone Redundancy vCore`.

## Product Names

| Config                                       | productName                                                                  |
| -------------------------------------------- | ---------------------------------------------------------------------------- |
| Single/Elastic Pool, General Purpose, Gen5   | `SQL Database Single/Elastic Pool General Purpose - Compute Gen5`            |
| Single/Elastic Pool, Business Critical, Gen5 | `SQL Database Single/Elastic Pool Business Critical - Compute Gen5`          |
| Serverless, General Purpose, Gen5            | `SQL Database General Purpose - Serverless - Compute Gen5`                   |
| Hyperscale, Gen5                             | `SQL Database SingleDB/Elastic Pool Hyperscale - Compute Gen5`               |
| Storage (General Purpose)                    | `SQL Database Single/Elastic Pool General Purpose - Storage`                 |
| Storage (Business Critical)                  | `SQL Database Single/Elastic Pool Business Critical - Storage`               |
| Storage (Hyperscale)                         | `SQL Database SingleDB Hyperscale - Storage` / `SQL Database Hyperscale - Storage` |
| PITR Backup Storage                          | `SQL Database Single/Elastic Pool PITR Backup Storage`                       |
| LTR Backup Storage                           | `SQL Database - LTR Backup Storage`                                          |

## Azure Hybrid Benefit

ServiceName: SQL Database
ProductName: SQL Database Single/Elastic Pool General Purpose - SQL License
Region: Global

> AHUB: compute `retailPrice` IS the AHUB rate. PAYG = compute + `sql_license_retailPrice` per vCore. Do NOT subtract. Swap productName for BC or Hyperscale (`SQL Database SingleDB/Elastic Pool Hyperscale - SQL License`). See shared.md AHUB section.
