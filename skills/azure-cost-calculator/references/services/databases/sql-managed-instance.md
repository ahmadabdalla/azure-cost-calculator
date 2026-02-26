---
serviceName: SQL Managed Instance
category: databases
aliases: [SQL MI, Azure SQL MI, Managed Instance]
billingConsiderations: [Azure Hybrid Benefit, Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure SQL Managed Instance

> **Trap (Inflated totals)**: Omitting `SkuName` returns all vCore sizes summed in `totalMonthlyCost`. Always include `SkuName` for compute queries.

> **Trap (Zone Redundancy)**: Zone-redundant deployments have separate meters (`Zone Redundancy vCore`) with skuNames like `8 vCore Zone Redundancy`. The ZR meter is an **additive hourly surcharge**, NOT a multiplier — sum both hourly rates, then × 730.

> **Trap (AHUB)**: vCore prices are license-included by default. For Azure Hybrid Benefit, you MUST query the SQL License product and subtract — see the Azure Hybrid Benefit section below. NEVER apply a percentage discount. If in batch mode, trigger a full read of this file when AHUB is requested.

## Query Pattern

### vCore compute (e.g., 8 vCore GP Gen5; swap productName for tier/series)

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Compute Gen5
SkuName: 8 vCore
MeterName: vCore

### Storage (General Purpose) — use Quantity for provisioned GB

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Storage
MeterName: General Purpose Data Stored
Quantity: 256

## Key Fields

| Parameter     | How to determine                               | Example values                                                          |
| ------------- | ---------------------------------------------- | ----------------------------------------------------------------------- |
| `serviceName` | Always `SQL Managed Instance`                  | `SQL Managed Instance`                                                  |
| `productName` | Tier + hardware series                         | See Product Names section below                                         |
| `skuName`     | vCore count — selects the size                 | `4 vCore`, `8 vCore`, `16 vCore`, `32 vCore`, `64 vCore`, `80 vCore`    |
| `meterName`   | `vCore` for compute, tier-specific for storage | `vCore`, `General Purpose Data Stored`, `Business Critical Data Stored` |

## Meter Names

| Meter                           | unitOfMeasure | Notes                              |
| ------------------------------- | ------------- | ---------------------------------- |
| `vCore`                         | `1 Hour`      | Compute meter for all tiers/series |
| `Zone Redundancy vCore`         | `1 Hour`      | Zone-redundancy compute surcharge  |
| `General Purpose Data Stored`   | `1 GB/Month`  | Storage for GP tier                |
| `Business Critical Data Stored` | `1 GB/Month`  | Storage for BC tier                |

## Cost Formula

```
Monthly Compute = retailPrice × 730 | Monthly Storage = storage_retailPrice × sizeInGB
Total = Monthly Compute + Monthly Storage
Zone-Redundant Compute = (base_retailPrice + zr_retailPrice) × 730
```

## Notes

- **Storage**: GP and BC storage billed separately per-GB. For BC, swap productName to `...Business Critical - Storage` and meterName to `Business Critical Data Stored`. PITR backup equal to max storage is free.
- **Tiers & Hardware**: GP/BC 4–80 vCores. BC includes In-Memory OLTP. Gen5 default; Premium Series / Memory Optimized offer newer hardware.

## Reserved Instance Pricing

### RI compute (swap productName for BC; omit SkuName — unitPrice is per-vCore)

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Compute Gen5
MeterName: vCore
PriceType: Reservation

> **Trap (RI skuName)**: RI `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero results. Calculate: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y).

## Azure Hybrid Benefit

### SQL License cost (Global-only, per-vCore; swap productName for BC)

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - SQL License
Region: Global

For license-included per-vCore price, query compute (line 20-25) but omit SkuName—same as RI pattern. AHUB hourly per-vCore = compute `retailPrice` − `sql_license_retailPrice`. Monthly = AHUB hourly × vCoreCount × 730. NEVER apply a percentage discount.

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
