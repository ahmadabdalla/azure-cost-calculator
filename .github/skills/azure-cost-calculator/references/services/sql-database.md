# Azure SQL Database

**Primary cost**: vCore hourly rate + storage per-GB/month

## Query Pattern

```powershell
# vCore compute (e.g., 2 vCore GP; swap productName for Business Critical)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool General Purpose - Compute Gen5' `
    -SkuName '2 vCore' `
    -MeterName 'vCore'
```

```powershell
# Storage — for BC: use '...Business Critical - Storage' + 'Business Critical Data Stored'
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool General Purpose - Storage' `
    -MeterName 'General Purpose Data Stored'
```

## Key Fields

| Parameter     | How to determine                                  | Example values                             |
| ------------- | ------------------------------------------------- | ------------------------------------------ |
| `serviceName` | Always `SQL Database`                             | `SQL Database`                             |
| `productName` | Deployment type + tier + generation               | See Product Names section below            |
| `skuName`     | vCore count — this selects the size               | `1 vCore`, `2 vCore`, `4 vCore`, `8 vCore` |
| `meterName`   | Always `vCore` for compute, or storage meter name | `vCore`, `General Purpose Data Stored`     |

## Meter Names

| Meter                           | unitOfMeasure | Notes                              |
| ------------------------------- | ------------- | ---------------------------------- |
| `vCore`                         | `1 Hour`      | Compute meter for all tiers        |
| `General Purpose Data Stored`   | `1 GB/Month`  | Storage for General Purpose tier   |
| `Business Critical Data Stored` | `1 GB/Month`  | Storage for Business Critical tier |

## Cost Formula

```
Monthly Compute = retailPrice × 730 | Monthly Storage = storage_retailPrice × sizeInGB
Total = Compute + Storage (unitPrice reflects total for selected vCore count)
```

## Notes

- **Default storage**: GP and BC default to 32 GB max data size. Storage billed separately — no "free included" storage in vCore model. Charged for configured max size, not usage. Backup storage equal to max data size is free.

## Reserved Instance Pricing

```powershell
# RI compute only (swap productName for BC). Returns 1-Year + 3-Year terms.
# Omit -SkuName for RI — unitPrice is per-vCore; multiply by your vCore count.
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool General Purpose - Compute Gen5' `
    -MeterName 'vCore' `
    -PriceType Reservation
```

> **Trap (RI skuName)**: RI `skuName='vCore'` (no count prefix). `-SkuName '8 vCore'` returns zero results.
> **Trap (RI MonthlyCost)**: See [pitfalls.md](../pitfalls.md). Calculate: `unitPrice × vCoreCount ÷ 12` (1Y) or `÷ 36` (3Y).

## Product Names

| Config                                       | productName                                                         |
| -------------------------------------------- | ------------------------------------------------------------------- |
| Single/Elastic Pool, General Purpose, Gen5   | `SQL Database Single/Elastic Pool General Purpose - Compute Gen5`   |
| Single/Elastic Pool, Business Critical, Gen5 | `SQL Database Single/Elastic Pool Business Critical - Compute Gen5` |
| Serverless, General Purpose, Gen5            | `SQL Database General Purpose - Serverless - Compute Gen5`          |
| Storage (General Purpose)                    | `SQL Database Single/Elastic Pool General Purpose - Storage`        |
| Storage (Business Critical)                  | `SQL Database Single/Elastic Pool Business Critical - Storage`      |
