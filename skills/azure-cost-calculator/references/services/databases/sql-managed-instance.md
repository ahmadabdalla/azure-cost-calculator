---
serviceName: SQL Managed Instance
category: databases
aliases: [SQL MI, Azure SQL MI, Managed Instance]
---

# Azure SQL Managed Instance

**Primary cost**: vCore hourly rate × 730 + storage per-GB/month

> **Trap (Zone Redundancy)**: Zone-redundant deployments have separate meters (`Zone Redundancy vCore`) with skuNames like `8 vCore Zone Redundancy`. Query the standard `vCore` meter first, then add the zone-redundancy surcharge if the user specifies zone redundancy.

## Query Pattern

```powershell
# vCore compute (e.g., 8 vCore GP Gen5; swap productName for tier/series)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Compute Gen5' `
    -SkuName '8 vCore' `
    -MeterName 'vCore'
```

```powershell
# Storage (General Purpose)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Storage' `
    -MeterName 'General Purpose Data Stored'
```

```powershell
# Storage (Business Critical)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance Business Critical - Storage' `
    -MeterName 'Business Critical Data Stored'
```

## Key Fields

| Parameter     | How to determine                    | Example values                                                        |
| ------------- | ----------------------------------- | --------------------------------------------------------------------- |
| `serviceName` | Always `SQL Managed Instance`       | `SQL Managed Instance`                                                |
| `productName` | Tier + hardware series              | See Product Names section below                                       |
| `skuName`     | vCore count — selects the size      | `4 vCore`, `8 vCore`, `16 vCore`, `32 vCore`, `64 vCore`, `80 vCore`  |
| `meterName`   | `vCore` for compute, tier-specific for storage | `vCore`, `General Purpose Data Stored`, `Business Critical Data Stored` |

## Meter Names

| Meter                                        | unitOfMeasure | Notes                                     |
| -------------------------------------------- | ------------- | ----------------------------------------- |
| `vCore`                                      | `1 Hour`      | Compute meter for all tiers/series        |
| `Zone Redundancy vCore`                      | `1 Hour`      | Zone-redundancy compute surcharge         |
| `General Purpose Data Stored`                | `1 GB/Month`  | Storage for General Purpose tier          |
| `General Purpose Zone Redundancy Data Stored`| `1 GB/Month`  | Zone-redundant GP storage                 |
| `Business Critical Data Stored`              | `1 GB/Month`  | Storage for Business Critical tier        |
| `Business Critical Zone Redundancy Data Stored` | `1 GB/Month` | Zone-redundant BC storage               |
| `General Purpose IO Rate Operations`         | `1M`          | IO operations for GP tier                 |
| `Business Critical IO Rate Operations`       | `1M`          | IO operations for BC tier                 |

## Cost Formula

```
Monthly Compute = retailPrice × 730
Monthly Storage = storage_retailPrice × sizeInGB
Total = Compute + Storage
```

## Notes

- **License included**: vCore prices include SQL Server license by default. Use Azure Hybrid Benefit (AHB) for existing SQL Server licenses at reduced rates — query with DevTestConsumption or check the Azure pricing page.
- **Storage**: GP storage is billed separately per-GB. BC tier includes local SSD storage; the storage meter covers data stored beyond the included allocation.
- **Backup storage**: PITR backup storage equal to instance max storage is free. Additional PITR and LTR backup storage are billed separately via `SQL Managed Instance PITR Backup Storage` and `SQL Managed Instance - LTR Backup Storage` products.

## Reserved Instance Pricing

```powershell
# RI compute (swap productName for BC). Returns 1-Year + 3-Year terms.
# Omit -SkuName for RI — unitPrice is per-vCore; multiply by your vCore count.
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Compute Gen5' `
    -MeterName 'vCore' `
    -PriceType Reservation
```

> **Trap (RI skuName)**: RI `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero results for reservations.
> **RI MonthlyCost trap** — see shared.md § Reserved Instance MonthlyCost. SQL MI-specific: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y).

## Product Names

| Config                                        | productName                                                                      |
| --------------------------------------------- | -------------------------------------------------------------------------------- |
| General Purpose, Gen5                         | `SQL Managed Instance General Purpose - Compute Gen5`                            |
| General Purpose, Premium Series               | `SQL Managed Instance General Purpose - Premium Series Compute`                  |
| General Purpose, Premium Series Mem Optimized | `SQL Managed Instance General Purpose - Premium Series Memory Optimized Compute` |
| Business Critical, Gen5                       | `SQL Managed Instance Business Critical - Compute Gen5`                          |
| Business Critical, Premium Series             | `SQL Managed Instance Business Critical - Premium Series Compute`                |
| Business Critical, Premium Series Mem Optimized | `SQL Managed Instance Business Critical - Premium Series Memory Optimized Compute` |
| Storage (General Purpose)                     | `SQL Managed Instance General Purpose - Storage`                                 |
| Storage (Business Critical)                   | `SQL Managed Instance Business Critical - Storage`                               |
