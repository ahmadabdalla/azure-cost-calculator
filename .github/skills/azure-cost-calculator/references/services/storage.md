# Storage Accounts (Blob)

**Multiple meters**: Data stored (per-GB/month), operations (per-10K), data retrieval, write operations

> **Trap (verified 2026-02-06)**: `productName = 'Blob Storage'` only works for **LRS** and **GRS** redundancy. ZRS and GZRS SKUs return **nothing** under `'Blob Storage'`. For ZRS/GZRS, use `productName = 'General Block Blob v2'` instead.

## Query Pattern

```powershell
# Data storage cost — LRS/GRS (productName: 'Blob Storage')
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'Hot LRS' `
    -ProductName 'Blob Storage' `
    -MeterName 'Hot LRS Data Stored'

# Data storage cost — ZRS (productName: 'General Block Blob v2')
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'Hot ZRS' `
    -ProductName 'General Block Blob v2' `
    -MeterName 'Hot ZRS Data Stored'

# Read operations
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'Hot LRS' `
    -ProductName 'Blob Storage' `
    -MeterName 'Hot Read Operations'

# Write operations
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'Hot LRS' `
    -ProductName 'Blob Storage' `
    -MeterName 'Hot LRS Write Operations'
```

## Key Fields

| Parameter     | How to determine         | Example values                                                           |
| ------------- | ------------------------ | ------------------------------------------------------------------------ |
| `skuName`     | Access tier + redundancy | `Hot LRS`, `Cool LRS`, `Hot GRS`, `Hot ZRS`                              |
| `productName` | Storage product type     | `Blob Storage`, `General Block Blob v2`, `Files v2`                      |
| `meterName`   | Specific meter           | `Hot LRS Data Stored`, `Hot Read Operations`, `Hot LRS Write Operations` |

## Cost Formula (tiered)

```
Storage is tiered — the API returns multiple items for same meter with different tierMinimumUnits:
  0-50 TB:       first tier price
  50-500 TB:     second tier price
  500+ TB:       third tier price

Monthly Storage = Σ(retailPrice × GB_in_tier)
Monthly Total   = Storage + (readOps/10000 × readPrice) + (writeOps/10000 × writePrice)

Note: Operation meter names include the access tier prefix:
  Hot tier:  'Hot Read Operations', 'Hot LRS Write Operations'
  Cool tier: 'Cool Read Operations', 'Cool LRS Write Operations'
```

## productName by Redundancy

| Redundancy | productName             | Notes                          |
| ---------- | ----------------------- | ------------------------------ |
| LRS        | `Blob Storage`          | Default                        |
| GRS        | `Blob Storage`          | Default                        |
| RA-GRS     | `Blob Storage`          | Default                        |
| ZRS        | `General Block Blob v2` | Different productName required |
| GZRS       | `General Block Blob v2` | Different productName required |
| RA-GZRS    | `General Block Blob v2` | Different productName required |

## GZRS / RA-GZRS Meter Reference (verified 2026-02-06)

> **Trap**: RA-GZRS and GZRS use **different skuNames** for data storage but **share** write/read operation meters. The naming is inconsistent — do not assume patterns from LRS/GRS apply.

### Data Stored

| Redundancy | skuName | meterName | productName |
| ---------- | ------- | --------- | ----------- |
| GZRS | `Hot GZRS` | `Hot GZRS Data Stored` | `General Block Blob v2` |
| RA-GZRS | `Hot RA-GZRS` | `Hot RA-GZRS Data Stored` | `General Block Blob v2` |

### Operations

| Operation | skuName | meterName | productName | Notes |
| --------- | ------- | --------- | ----------- | ----- |
| Write (GZRS & RA-GZRS) | `Hot GZRS` | `Hot GZRS Write Operations` | `General Block Blob v2` | Shared across GZRS and RA-GZRS |
| Read (all redundancies) | _(any Hot SKU)_ | `Hot Read Operations` | `General Block Blob v2` | Generic — not redundancy-specific |

> **Trap (RA-GZRS vs GZRS pricing)**: RA-GZRS data storage is **~25% more expensive** than GZRS (e.g., €0.0446 vs €0.0357/GB in tier 1, northeurope). Using `Hot GZRS` skuName instead of `Hot RA-GZRS` will significantly under-price large storage accounts.

### Query Examples — RA-GZRS

```powershell
# RA-GZRS Data Stored (tiered pricing)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'Hot RA-GZRS' `
    -ProductName 'General Block Blob v2' `
    -MeterName 'Hot RA-GZRS Data Stored'

# RA-GZRS Write Operations (uses GZRS skuName!)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'Hot GZRS' `
    -ProductName 'General Block Blob v2' `
    -MeterName 'Hot GZRS Write Operations'

# RA-GZRS Read Operations (generic meter)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -ProductName 'General Block Blob v2' `
    -MeterName 'Hot Read Operations'
```

## Common Redundancy Options

| Code   | Full name                         |
| ------ | --------------------------------- |
| LRS    | Locally Redundant Storage         |
| ZRS    | Zone Redundant Storage            |
| GRS    | Geo Redundant Storage             |
| RA-GRS | Read-Access Geo Redundant Storage |
| GZRS    | Geo-Zone Redundant Storage                     |
| RA-GZRS | Read-Access Geo-Zone Redundant Storage         |
