---
serviceName: SQL Managed Instance
category: databases
aliases: [SQL MI, Azure SQL MI, Managed Instance]
billingConsiderations: [Azure Hybrid Benefit, Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage/backup per-GB/month"
privateEndpoint: true
---

# Azure SQL Managed Instance

> **Trap (Inflated totals)**: Omitting `ProductName`, `SkuName`, or `MeterName` can sum every compute size, storage, backup, and add-on meter. Always filter all three for estimates.

> **Trap (Zone Redundancy)**: Zone-redundant deployments have separate meters (`Zone Redundancy vCore`) with skuNames like `8 vCore Zone Redundancy`. The ZR meter is an **additive hourly surcharge**, NOT a multiplier. Sum both hourly rates, then × 730. For GP Premium Series and GP Premium Series Memory Optimized, the generic `vCore ZR Zone Redundancy` skuName returns an anomalous near-zero rate; always use numbered ZR SKUs (e.g., `8 vCore Zone Redundancy`) for consumption queries.

> **Trap (AHUB)**: vCore compute prices are **base rates only** (infrastructure, no license). Under PAYG, Azure bills a separate SQL License meter (Global) as an add-on. For AHUB, only the compute meter applies; the compute `retailPrice` IS the AHUB price. **Do NOT subtract.** NEVER apply a percentage discount. If in batch mode, trigger a full read of this file when AHUB is requested.

## Query Pattern

### vCore compute (e.g., 8 vCore GP Gen5; swap productName for tier/series)

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Compute Gen5
SkuName: 8 vCore
MeterName: vCore

### Storage (General Purpose): use Quantity for provisioned GB

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Storage
SkuName: General Purpose
MeterName: General Purpose Data Stored
Quantity: 256

### PITR backup over included allowance

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance PITR Backup Storage
SkuName: Backup LRS
MeterName: LRS Data Stored
Quantity: 100

## Key Fields

| Parameter     | How to determine                               | Example values                                                                               |
| ------------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `serviceName` | Always `SQL Managed Instance`                  | `SQL Managed Instance`                                                                       |
| `productName` | Tier + hardware series                         | See Product Names section below                                                              |
| `skuName`     | vCore count, selects the size                  | `4 vCore`, `8 vCore`, `16 vCore`, `24 vCore`, `32 vCore`, `40 vCore`, `64 vCore`, `80 vCore` |
| `meterName`   | `vCore` for compute, tier-specific for storage | `vCore`, `General Purpose Data Stored`, `Business Critical Data Stored`                      |

## Meter Names

| Meter                                          | unitOfMeasure | Notes                                  |
| ---------------------------------------------- | ------------- | -------------------------------------- |
| `vCore`                                        | `1 Hour`      | Compute meter for all tiers/series     |
| `Zone Redundancy vCore`                        | `1 Hour`      | Zone-redundancy compute surcharge      |
| `General Purpose Data Stored`                  | `1 GB/Month`  | Storage for GP tier                    |
| `General Purpose Zone Redundancy Data Stored`  | `1 GB/Month`  | ZR storage for GP                      |
| `Business Critical Data Stored`                | `1 GB/Month`  | Storage for BC tier                    |
| `Business Critical Zone Redundancy Data Stored`| `1 GB/Month`  | ZR storage for BC                      |
| `General Purpose IO Rate Operations`           | `1M`          | Optional IO operations                 |
| `Business Critical IO Rate Operations`         | `1M`          | Optional IO operations                 |
| `Additional IOPS`                              | `1 IOPS/Month`| Next-gen GP provisioned IOPS add-on    |
| `Additional IOPS - Zone Redundant`             | `1 IOPS/Month`| ZR provisioned IOPS add-on             |
| `Addl Memory Additional Memory`                | `1 GB/Hour`   | Optional GP additional memory          |
| `Addl Mm Additional Memory`                    | `1 GB/Hour`   | Optional BC Premium additional memory  |
| `LRS Data Stored`                              | `1 GB/Month`  | PITR backup over included allowance    |
| `LTR Backup LRS Data Stored`                   | `1 GB/Month`  | LTR backup storage                     |

## Cost Formula
```
compute_retailPrice = SKU-total hourly (queried with SkuName) | sql_license_retailPrice = per-vCore hourly (queried without SkuName)
PAYG Monthly = (compute_retailPrice + sql_license_retailPrice × vCoreCount) × 730 + storage_retailPrice × sizeInGB
AHUB Monthly = compute_retailPrice × 730 + storage_retailPrice × sizeInGB
Monthly Backup = backup_retailPrice × billableBackupGB
Monthly IO = (ioOperations / 1,000,000) × io_retailPrice + extraIOPS × iops_retailPrice
Monthly Memory = memory_retailPrice × extraMemoryGB × 730
Zone-Redundant = substitute (compute_retailPrice + zr_retailPrice) for compute_retailPrice above
```

## Notes
- **Storage**: GP and BC storage are billed separately per configured max GB. For BC, swap productName to `...Business Critical - Storage` and meterName to `Business Critical Data Stored`.
- **Backups**: PITR backup equal to max storage is included; bill overage with `SQL Managed Instance PITR Backup Storage`. LTR uses `SQL Managed Instance - LTR Backup Storage` with LRS/ZRS/RA-GRS/RA-GZRS variants.
- **Next-gen GP**: Microsoft Learn says billing still reflects General Purpose; the API has no `Next` productName. Bill baseline GP compute/storage plus optional IOPS and memory add-on meters. Zone redundancy is not available.
- **Tiers & Hardware**: GP/BC 4–80 vCores in API. BC includes In-Memory OLTP. Gen5 default; Premium Series / Memory Optimized offer newer hardware. Gen4 exists in API but is deprecated.
- **Private endpoints**: Supported with target sub-resource `managedInstance`; SQL traffic uses port 1433 and requires hostname-based DNS.

## Reserved Instance Pricing
### RI compute (swap productName for BC; unitPrice is per-vCore)

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Compute Gen5
SkuName: vCore
MeterName: vCore
PriceType: Reservation

> **Trap (RI skuName)**: RI uses `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero. Calculate: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y). For ZR RI, use `SkuName: vCore ZR Zone Redundancy` and `MeterName: Zone Redundancy vCore`. RI prices are already license-excluded; do NOT subtract SQL License.

## Azure Hybrid Benefit
ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - SQL License
SkuName: vCore
Region: Global

> **Note**: AHUB: compute `retailPrice` IS the AHUB rate. PAYG = `(compute_retailPrice + sql_license_retailPrice × vCoreCount) × 730 + storage + backup`. Do NOT subtract. Swap `productName` for BC license.

## Product Names
| Config                                          | productName                                                                        |
| ----------------------------------------------- | ---------------------------------------------------------------------------------- |
| General Purpose, Gen5                           | `SQL Managed Instance General Purpose - Compute Gen5`                              |
| General Purpose, Premium Series                 | `SQL Managed Instance General Purpose - Premium Series Compute`                    |
| General Purpose, Premium Series Mem Optimized   | `SQL Managed Instance General Purpose - Premium Series Memory Optimized Compute`   |
| Business Critical, Gen5                         | `SQL Managed Instance Business Critical - Compute Gen5`                            |
| Business Critical, Premium Series               | `SQL Managed Instance Business Critical - Premium Series Compute`                  |
| Business Critical, Premium Series Mem Optimized | `SQL Managed Instance Business Critical - Premium Series Memory Optimized Compute` |
| SQL License (General Purpose)                   | `SQL Managed Instance General Purpose - SQL License`                               |
| SQL License (Business Critical)                 | `SQL Managed Instance Business Critical - SQL License`                             |
| Storage (General Purpose)                       | `SQL Managed Instance General Purpose - Storage`                                   |
| Storage (Business Critical)                     | `SQL Managed Instance Business Critical - Storage`                                 |
