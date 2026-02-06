# Key Vault

**Primary cost**: Operations (per-10K) + secrets/keys/certificates stored

> **Trap**: Querying with only `-SkuName 'Standard'` (no `-ProductName` or `-MeterName`) returns **Azure Dedicated HSM** (thousands per month) mixed in with standard Key Vault operations (sub-dollar per 10K ops). The `summary.totalMonthlyCost` is wildly misleading. Always filter by `-ProductName 'Key Vault'` or use a specific `-MeterName`.

## Query Pattern

```powershell
# Recommended: filter by productName to exclude Dedicated HSM
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Standard' `
    -ProductName 'Key Vault'

# Or query specific meters individually:
# Standard operations (secrets, keys read/write)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Standard' `
    -ProductName 'Key Vault' `
    -MeterName 'Operations'

# Advanced key operations (RSA/EC crypto)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Standard' `
    -ProductName 'Key Vault' `
    -MeterName 'Advanced Key Operations'
```

## Meter Names

| Meter                         | unitOfMeasure | Notes                           |
| ----------------------------- | ------------- | ------------------------------- |
| `Operations`                  | 10K           | Standard secret/key read/write  |
| `Advanced Key Operations`     | 10K           | RSA/EC cryptographic operations |
| `Certificate Renewal Request` | 1             | Per certificate renewal         |
| `Secret Renewal`              | 1             | Per secret auto-renewal         |
| `Automated Key Rotation`      | 1 Rotation    | Per key auto-rotation event     |

> **Do NOT use**: `Standard Instance` meter — that is Azure Dedicated HSM (thousands per month). Always filter by `-ProductName 'Key Vault'`.

## Cost Formula

```
Monthly = (operations/10000 × operations_price) + (advancedOps/10000 × advancedOps_price)
```

## Typical Cost Estimate

For a standard application (~10-20 secrets, ~100K operations/month):

```
Operations: 100,000/10,000 × operations_unitPrice (typically < $1/month — query live price)
```

Key Vault is effectively negligible (<$1/month) for most workloads.

## Premium Tier — HSM-Protected Keys

Premium tier adds HSM-backed key support. Query with `-SkuName 'Premium'`:

```powershell
# Premium operations (same price as Standard)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Premium' `
    -ProductName 'Key Vault' `
    -MeterName 'Operations'

# HSM-protected RSA 2048-bit keys
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Premium' `
    -ProductName 'Key Vault' `
    -MeterName 'Premium HSM-protected RSA 2048-bit key'

# HSM-protected Advanced Key (tiered pricing — see trap below)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Premium' `
    -ProductName 'Key Vault' `
    -MeterName 'Premium HSM-protected Advanced Key'
```

### Premium Meter Reference

| Meter                                    | unitOfMeasure | Notes                       |
| ---------------------------------------- | ------------- | --------------------------- |
| `Operations`                             | 10K           | Same as Standard            |
| `Premium HSM-protected RSA 2048-bit key` | 1/Month       | Per key, per month          |
| `Premium HSM-protected Advanced Key`     | 1/Month       | Per key, tiered — see below |

> **Trap**: `Premium HSM-protected Advanced Key` has **4 pricing tiers** based on `tierMinimumUnits`. A simple query returns all tiers and the summary total is meaningless.

### HSM Advanced Key Tier Pricing

There are 4 pricing tiers based on key count: 0–249, 250–1,499, 1,500–3,999, and 4,000+. Query live prices for current per-key rates.

Most deployments use <250 keys.

## Notes

- Standard vs Premium tier (Premium adds HSM-backed keys)
- Operations include vault reads, writes, list operations
- Software-protected keys: included in operations cost
- HSM-protected keys: separate per-key pricing (Premium tier only)
