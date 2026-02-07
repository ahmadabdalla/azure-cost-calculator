---
serviceName: Key Vault
category: security
aliases: [keyvault, KV, vault]
---

# Key Vault

**Primary cost**: Operations (per-10K) + secrets/keys/certificates stored

> **Trap**: Querying with only `-SkuName 'Standard'` (no `-ProductName`) returns **Azure Dedicated HSM** (thousands/month) mixed with Key Vault ops. Always filter by `-ProductName 'Key Vault'`.

## Query Pattern

```powershell
# Standard tier — filter by productName to exclude Dedicated HSM
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Standard' `
    -ProductName 'Key Vault'
# Add -MeterName 'Operations' or 'Advanced Key Operations' to isolate specific meters

# Premium tier — HSM-backed keys
.\Get-AzurePricing.ps1 `
    -ServiceName 'Key Vault' `
    -SkuName 'Premium' `
    -ProductName 'Key Vault'
# Add -MeterName for specific Premium meters (see table below)
```

## Meter Names

| Meter                                    | SKU              | unitOfMeasure | Notes                            |
| ---------------------------------------- | ---------------- | ------------- | -------------------------------- |
| `Operations`                             | Standard/Premium | 10K           | Secret/key read/write            |
| `Advanced Key Operations`                | Standard         | 10K           | RSA/EC cryptographic ops         |
| `Certificate Renewal Request`            | Standard         | 1             | Per certificate renewal          |
| `Secret Renewal`                         | Standard         | 1             | Per secret auto-renewal          |
| `Automated Key Rotation`                 | Standard         | 1 Rotation    | Per key auto-rotation            |
| `Premium HSM-protected RSA 2048-bit key` | Premium          | 1/Month       | Per HSM key, per month           |
| `Premium HSM-protected Advanced Key`     | Premium          | 1/Month       | Per key, tiered — see trap below |

> **Do NOT use**: `Standard Instance` meter — that is Azure Dedicated HSM (thousands/month).

> **Trap (Premium HSM Advanced Key)**: Has **4 pricing tiers** based on `tierMinimumUnits` (0–249, 250–1499, 1500–3999, 4000+). Query returns all tiers — summary total is meaningless. Most deployments use <250 keys.

## Cost Formula

```
Monthly = (operations/10000 × ops_price) + (advancedOps/10000 × advOps_price)
# Premium: add per-key HSM charges (RSA 2048 + Advanced Key at applicable tier)
```

## Notes

- Standard vs Premium: Premium adds HSM-backed keys with separate per-key pricing.
- Software-protected keys included in operations cost; HSM-protected keys are separate (Premium only).
- Operations include vault reads, writes, and list operations.
