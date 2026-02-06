# Azure SQL Database

**Primary cost**: vCore hourly rate + storage per-GB/month

## Query Pattern

```powershell
# vCore compute cost (2 vCore General Purpose)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool General Purpose - Compute Gen5' `
    -SkuName '2 vCore' `
    -MeterName 'vCore'

# Storage cost (General Purpose)
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool General Purpose - Storage' `
    -MeterName 'General Purpose Data Stored'

# Business Critical storage query
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool Business Critical - Storage' `
    -MeterName 'Business Critical Data Stored'
```

## Key Fields

| Parameter     | How to determine                                  | Example values                             |
| ------------- | ------------------------------------------------- | ------------------------------------------ |
| `serviceName` | Always `SQL Database`                             | `SQL Database`                             |
| `productName` | Deployment type + tier + generation               | See Product Names section below            |
| `skuName`     | vCore count — this selects the size               | `1 vCore`, `2 vCore`, `4 vCore`, `8 vCore` |
| `meterName`   | Always `vCore` for compute, or storage meter name | `vCore`, `General Purpose Data Stored`     |

## Meter Names (verified 2026-02-06)

| Meter                           | unitOfMeasure | Notes                              |
| ------------------------------- | ------------- | ---------------------------------- |
| `vCore`                         | `1 Hour`      | Compute meter for all tiers        |
| `General Purpose Data Stored`   | `1 GB/Month`  | Storage for General Purpose tier   |
| `Business Critical Data Stored` | `1 GB/Month`  | Storage for Business Critical tier |

## Cost Formula

```
Monthly Compute = retailPrice × 730 hours
  (unitPrice already reflects total cost for the selected skuName vCore count)
Monthly Storage = storage_retailPrice × sizeInGB
Total = Compute + Storage
```

## Notes

- `skuName` determines vCore count — no quantity multiplier needed for compute
- The price per vCore varies by tier (Business Critical ~3× General Purpose)
- Elastic Pools share the same `productName` as Single DB
- **Default storage (verified 2026-02-06)**: Both General Purpose and Business Critical default to 32 GB max data size. Storage is always billed separately from compute at the tier’s per-GB rate — there is no "free included" data storage in the vCore model. You are charged for the configured maximum data size, not actual usage. Backup storage equal to the configured max data size is provided at no extra charge.

## Reserved Instance Pricing

```powershell
# RI for Business Critical (returns both 1-Year and 3-Year terms)
# NOTE: Do NOT use '-SkuName 8 vCore' — RI items use skuName='vCore' (no count prefix)
# The returned unitPrice is per-vCore. Multiply by your vCore count.
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool Business Critical - Compute Gen5' `
    -MeterName 'vCore' `
    -PriceType Reservation

# RI for General Purpose
.\Get-AzurePricing.ps1 `
    -ServiceName 'SQL Database' `
    -ProductName 'SQL Database Single/Elastic Pool General Purpose - Compute Gen5' `
    -MeterName 'vCore' `
    -PriceType Reservation
```

> **Note**: Reserved Instance pricing applies to compute only — storage is always pay-as-you-go. The API returns the **total prepaid cost per vCore** for the reservation term. To get monthly cost for an 8-vCore pool: `unitPrice × 8 ÷ 12` (1-Year) or `unitPrice × 8 ÷ 36` (3-Years). The `reservationTerm` field in the response confirms the term length. Both 1-Year and 3-Year results are returned in a single query — select the desired term from the results.
>
> **Trap (RI skuName — verified 2026-02-06)**: For Reservation pricing, the `skuName` is `'vCore'` (NOT `'8 vCore'`). If you include `-SkuName '8 vCore'` on an RI query, the API returns **zero results**. Only use `-SkuName` for PAYG queries. For RI queries, omit `-SkuName` and multiply the per-vCore price by your vCore count manually.
>
> **Trap (RI MonthlyCost — verified 2026-02-06)**: The script's `MonthlyCost` is **wildly wrong** for Reservation items. It multiplies the total term price by 730 hours, producing absurd values (e.g., £million+). **Always ignore the script's `MonthlyCost`** for Reservation items and manually calculate: `unitPrice × vCoreCount ÷ 12` for 1-Year monthly cost, or `unitPrice × vCoreCount ÷ 36` for 3-Year monthly cost.

## Product Names (case-sensitive)

| Config                                       | productName                                                         |
| -------------------------------------------- | ------------------------------------------------------------------- |
| Single/Elastic Pool, General Purpose, Gen5   | `SQL Database Single/Elastic Pool General Purpose - Compute Gen5`   |
| Single/Elastic Pool, Business Critical, Gen5 | `SQL Database Single/Elastic Pool Business Critical - Compute Gen5` |
| Serverless, General Purpose, Gen5            | `SQL Database General Purpose - Serverless - Compute Gen5`          |
| Storage (General Purpose)                    | `SQL Database Single/Elastic Pool General Purpose - Storage`        |
| Storage (Business Critical)                  | `SQL Database Single/Elastic Pool Business Critical - Storage`      |
