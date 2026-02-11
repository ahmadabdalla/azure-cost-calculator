---
serviceName: SQL Managed Instance
category: databases
aliases: [SQL MI, Azure SQL MI, Managed Instance]
---

# Azure SQL Managed Instance

**Primary cost**: vCore hourly rate × 730 + storage per-GB/month

> **Trap (Inflated totals)**: Omitting `SkuName` returns all vCore sizes summed in `totalMonthlyCost`. Always include `SkuName` for compute queries.

> **Trap (Zone Redundancy)**: Zone-redundant deployments have separate meters (`Zone Redundancy vCore`) with skuNames like `8 vCore Zone Redundancy`. Query the standard `vCore` meter first, then add the zone-redundancy surcharge.

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

Zone-redundant storage meters append `Zone Redundancy` (e.g., `General Purpose Zone Redundancy Data Stored`). IO meters: `General Purpose IO Rate Operations` / `Business Critical IO Rate Operations` (`1M`).

## Cost Formula

```
Monthly Compute = retailPrice × 730
Monthly Storage = storage_retailPrice × sizeInGB
Total = Monthly Compute + Monthly Storage
```

## Notes

- **License included vs AHB**: vCore prices are license-included by default. AHB prices appear as separate items with "Azure Hybrid Benefit" or "Base rate" in `productName`/`skuName`.
- **Storage**: GP and BC storage billed separately per-GB. For BC storage, swap productName to `...Business Critical - Storage` and meterName to `Business Critical Data Stored`.
- **Backup**: PITR backup equal to max storage is free. Extra PITR/LTR billed via `SQL Managed Instance PITR Backup Storage` and `SQL Managed Instance - LTR Backup Storage`.
- **Tier limits**: GP supports 4–80 vCores (Gen5/Premium Series). BC supports 4–80 vCores and includes In-Memory OLTP. Premium Series Memory Optimized offers higher memory-per-vCore.
- **Hardware**: Gen5 is the default. Premium Series and Premium Series Memory Optimized offer newer hardware. Gen4 is legacy (limited availability).

## Reserved Instance Pricing

### RI compute (swap productName for BC). Returns 1-Year + 3-Year terms.

### Omit SkuName for RI — unitPrice is per-vCore; multiply by your vCore count.

ServiceName: SQL Managed Instance
ProductName: SQL Managed Instance General Purpose - Compute Gen5
MeterName: vCore
PriceType: Reservation

> **Trap (RI skuName)**: RI `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero results for reservations. MonthlyCost is wildly wrong — see shared.md & RI MonthlyCost. Calculate: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y).

## Product Names

| Config                                          | productName                                                                        |
| ----------------------------------------------- | ---------------------------------------------------------------------------------- |
| General Purpose, Gen5                           | `SQL Managed Instance General Purpose - Compute Gen5`                              |
| General Purpose, Premium Series                 | `SQL Managed Instance General Purpose - Premium Series Compute`                    |
| General Purpose, Premium Series Mem Optimized   | `SQL Managed Instance General Purpose - Premium Series Memory Optimized Compute`   |
| Business Critical, Gen5                         | `SQL Managed Instance Business Critical - Compute Gen5`                            |
| Business Critical, Premium Series               | `SQL Managed Instance Business Critical - Premium Series Compute`                  |
| Business Critical, Premium Series Mem Optimized | `SQL Managed Instance Business Critical - Premium Series Memory Optimized Compute` |
| Storage (General Purpose)                       | `SQL Managed Instance General Purpose - Storage`                                   |
| Storage (Business Critical)                     | `SQL Managed Instance Business Critical - Storage`                                 |
