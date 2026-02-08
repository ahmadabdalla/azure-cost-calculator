---
serviceName: SQL Managed Instance
category: databases
aliases: [SQL MI, Azure SQL MI, Managed Instance]
---

# Azure SQL Managed Instance

**Primary cost**: vCore hourly rate × vCoreCount × 730 + storage per-GB/month

> **Trap**: `skuName` is always `vCore` — the API returns a per-vCore unit price. Multiply `retailPrice × vCoreCount × 730` for monthly compute. Do not expect `skuName` values like `4 vCore` or `8 vCore`.

## Query Pattern

```powershell
# vCore compute (General Purpose Gen5; swap productName for Business Critical)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Compute Gen5' `
    -MeterName 'vCore'
```

```powershell
# Storage (General Purpose; for BC use '...Business Critical - Storage')
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Storage' `
    -MeterName 'Data Stored'
```

```powershell
# PITR Backup storage
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Storage' `
    -MeterName 'PITR Backup Storage'
```

## Key Fields

| Parameter     | How to determine                          | Example values                                  |
| ------------- | ----------------------------------------- | ----------------------------------------------- |
| `serviceName` | Always `SQL Managed Instance`             | `SQL Managed Instance`                          |
| `productName` | Tier + Compute/Storage (see table below)  | See Product Names section                       |
| `skuName`     | Always `vCore` for compute                | `vCore`                                         |
| `meterName`   | `vCore` for compute, storage meter varies | `vCore`, `Data Stored`, `PITR Backup Storage`   |

## Meter Names

| Meter                 | unitOfMeasure | Notes                                        |
| --------------------- | ------------- | -------------------------------------------- |
| `vCore`               | `1 Hour`      | Per-vCore compute; multiply by vCore count   |
| `Data Stored`         | `1 GB/Month`  | Provisioned data storage                     |
| `PITR Backup Storage` | `1 GB/Month`  | Point-in-time restore backup beyond included |

## Cost Formula

```
Monthly Compute = retailPrice × vCoreCount × 730
Monthly Storage = storage_retailPrice × sizeInGB
Monthly Backup  = backup_retailPrice × max(0, backupGB - includedBackupGB)
Total = Compute + Storage + Backup
```

## Notes

- vCore counts: 4, 8, 16, 24, 32, 40, 64, 80 (General Purpose); 4, 8, 16, 24, 32, 40, 64, 80 (Business Critical)
- Storage: GP supports 32 GB–16 TB; BC supports 32 GB–4 TB (up to 16 TB in select regions)
- Backup: 7 days of PITR backup storage included at no extra cost; additional retention billed per-GB/month
- Business Critical includes a free readable secondary replica
- SQL MI pricing is per-vCore (unlike SQL Database which has per-size SKUs) — always multiply by your vCore count

## Reserved Instance Pricing

```powershell
# RI compute (swap productName for BC). Returns 1-Year + 3-Year terms.
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Managed Instance' `
    -ProductName 'SQL Managed Instance General Purpose - Compute Gen5' `
    -MeterName 'vCore' `
    -PriceType Reservation
```

> **Trap (RI MonthlyCost)**: The script's `MonthlyCost` is wrong for Reservation items.
> Manually calculate: `unitPrice × vCoreCount ÷ 12` (1-Year) or `unitPrice × vCoreCount ÷ 36` (3-Year).

## Product Names

| Config                          | productName                                                  |
| ------------------------------- | ------------------------------------------------------------ |
| General Purpose, Compute Gen5   | `SQL Managed Instance General Purpose - Compute Gen5`        |
| Business Critical, Compute Gen5 | `SQL Managed Instance Business Critical - Compute Gen5`      |
| Storage (General Purpose)       | `SQL Managed Instance General Purpose - Storage`             |
| Storage (Business Critical)     | `SQL Managed Instance Business Critical - Storage`           |
