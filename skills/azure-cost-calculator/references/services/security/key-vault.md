---
serviceName: Key Vault
category: security
aliases: [AKV, KV, Managed HSM]
primaryCost: "Operations (per-10K); Premium adds per-HSM-key monthly charges"
privateEndpoint: true
---

# Key Vault

> **Trap**: Querying with only `SkuName 'Standard'` (no `ProductName`) returns **Azure Dedicated HSM** (thousands/month) mixed with Key Vault ops. Always filter by `ProductName 'Key Vault'`.

## Query Pattern

### Standard tier — filter by productName to exclude Dedicated HSM

ServiceName: Key Vault
SkuName: Standard
ProductName: Key Vault
MeterName: Operations
Quantity: 100  # 100 × 10K = 1M operations/month

> For cryptographic operations, use `MeterName: Advanced Key Operations` instead.

### Premium tier — HSM-backed keys

ServiceName: Key Vault
SkuName: Premium
ProductName: Key Vault
MeterName: Operations

> For HSM-protected keys, see the Meter Names table for Premium-specific meters.

## Meter Names

| Meter                                    | SKU              | unitOfMeasure | Notes                            |
| ---------------------------------------- | ---------------- | ------------- | -------------------------------- |
| `Operations`                             | Standard/Premium | 10K           | Secret/key read/write            |
| `Advanced Key Operations`                | Standard/Premium | 10K           | RSA/EC cryptographic ops         |
| `Certificate Renewal Request`            | Standard/Premium | 1             | Per certificate renewal          |
| `Secret Renewal`                         | Standard/Premium | 1             | Per secret auto-renewal          |
| `Automated Key Rotation`                 | Standard/Premium | 1 Rotation    | Per key auto-rotation            |
| `Premium HSM-protected RSA 2048-bit key` | Premium          | 1/Month       | Per HSM key, per month           |
| `Premium HSM-protected Advanced Key`     | Premium          | 1/Month       | Per key, tiered — see trap below |

> **Do NOT use**: `Standard Instance` meter — that is Azure Dedicated HSM (thousands/month).

> **Trap (Premium HSM Advanced Key)**: Has **4 pricing tiers** based on `tierMinimumUnits` (0–249, 250–1499, 1500–3999, 4000+). Query returns all tiers — summary total is meaningless. Most deployments use <250 keys.

> **Trap (Premium HSM meter relationships)**: `Operations (Premium)` is **always charged**. For each HSM key, charge **exactly one** key meter — `Premium HSM-protected RSA 2048-bit key` and `Premium HSM-protected Advanced Key` are **mutually exclusive** (RSA 2048 → RSA meter; RSA 3072/4096 or EC → Advanced Key meter). Never charge both for the same key.

## Cost Formula

```
Monthly = (operations/10000 × ops_price) + (advancedOps/10000 × advOps_price)
### Premium: add per-key HSM charges (RSA 2048 + Advanced Key at applicable tier)
```

## Notes

- Standard vs Premium: Premium adds HSM-backed keys with separate per-key pricing. All Standard meters also exist under Premium at identical prices.
- Software-protected keys included in operations cost; HSM-protected keys are separate (Premium only).
- `Operations` include vault reads, writes, and list operations. Cryptographic operations (RSA/EC) are billed under the `Advanced Key Operations` meter. Estimate operation count from expected app request rates (each secret read = 1 operation).
- **Managed HSM** (`Key Vault HSM Pool` in API, `Standard B1` SKU) is a dedicated single-tenant HSM pool billed at hourly rate — query with `ProductName: Key Vault HSM Pool`.
