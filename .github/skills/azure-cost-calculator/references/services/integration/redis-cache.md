---
serviceName: Redis Cache
category: integration
aliases: [Redis, Azure Cache for Redis, cache]
---

# Redis Cache

**Primary cost**: Cache instance hours based on tier and size

## Query Pattern

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -MeterName 'C1 Cache Instance'
```

> **Note:** The Azure Portal calls this "Azure Cache for Redis" but the Retail Prices API uses `Redis Cache` as the `serviceName`.

## Meter Names

Format: `{tier_prefix}{size} Cache Instance`

- Basic/Standard: `C0`–`C6` (use productName to distinguish tier)
- Premium: `P1`–`P5`

## Product Names

| Tier             | productName                          | skuName examples                                        | Notes                               |
| ---------------- | ------------------------------------ | ------------------------------------------------------- | ----------------------------------- |
| Basic            | `Azure Redis Cache Basic`            | `C0`–`C6`                                               | No HA, no replication               |
| Standard         | `Azure Redis Cache Standard`         | `C0`–`C6`                                               | HA with replication                 |
| Premium          | `Azure Redis Cache Premium`          | `P1`–`P5`                                               | Clustering, persistence, VNet       |
| Enterprise       | `Azure Redis Cache Enterprise`       | `E1`, `E5`, `E10`, `E20`, `E50`, `E100`, `E200`, `E400` | Redis Stack, active geo-replication |
| Enterprise Flash | `Azure Redis Cache Enterprise Flash` | `F300`, `F700`, `F1500`                                 | Flash-optimized, large datasets     |

> **Trap (duplicate meters)**: Standard and Premium tiers return **two meters per size** — e.g., `C1 Cache` AND `C1 Cache Instance`. The `Cache Instance` meter is typically **half the price** of the `Cache` meter. Use `Cache Instance` for per-instance pricing (which is what the portal shows). The `Cache` meter appears to represent the total including replication. Basic tier only has `{size} Cache` (no `Cache Instance` variant).
> **Trap (Basic meter name)**: Basic tier uses `C0 Cache`, `C1 Cache`, etc. (**not** `Cache Instance`). Standard/Premium use `Cache Instance`. To avoid confusion, always include `-ProductName` to filter by tier.

### Recommended Query Pattern (with productName filter)

```powershell
# Basic C1
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -ProductName 'Azure Redis Cache Basic' `
    -MeterName 'C1 Cache'

# Standard C1
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -ProductName 'Azure Redis Cache Standard' `
    -MeterName 'C1 Cache Instance'

# Premium P1
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -ProductName 'Azure Redis Cache Premium' `
    -MeterName 'P1 Cache Instance'
```

## Cost Formula

```
Monthly = retailPrice × 730 hours × shardCount × (1 + replicas)
```

## Reserved Instance Pricing

RIs available for **Premium only** (P1-P5). Returns both 1-Year and 3-Year terms. Divide `retailPrice` by 12 (1-Year) or 36 (3-Year) for monthly cost.

```powershell
# RI for Premium — substitute {Size} with P1-P5
.\Get-AzurePricing.ps1 `
    -ServiceName 'Redis Cache' `
    -MeterName '{Size} Cache Instance' `
    -PriceType Reservation
```

> **Trap (RI MonthlyCost)**: See [reserved-instances.md](../../reserved-instances.md). Manually calculate: `unitPrice ÷ 12` (1-Year) or `÷ 36` (3-Year).
