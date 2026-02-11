---
serviceName: Redis Cache
category: databases
aliases: [Redis, Azure Cache for Redis, cache]
---

# Redis Cache

**Primary cost**: Cache instance hours based on tier and size

> **Trap (duplicate meters)**: Standard and Premium tiers return **two meters per size** — e.g., `P1 Cache` AND `P1 Cache Instance`. The `{Size} Cache` meter is the **total cluster cost** (2 nodes with HA); `{Size} Cache Instance` is exactly **half** (per-node). **Use `{Size} Cache` for total cost matching the Azure Portal.** Basic and Enterprise tiers only have `{Size} Cache` (no `Cache Instance` variant).

> **Trap (Premium P1 ambiguity)**: Querying `meterName eq 'P1 Cache Instance'` returns **multiple results**: Consumption pricing (per-node hourly) AND Reservation pricing (1-Year/3-Year). Always filter with `type eq 'Consumption'` or `priceType eq 'Consumption'` to get deterministic results.

> **Trap (Basic meter name)**: Basic tier uses `C0 Cache`, `C1 Cache`, etc. (**not** `Cache Instance`). Always include `ProductName` to filter by tier.

> **Note:** The Azure Portal calls this "Azure Cache for Redis" but the Retail Prices API uses `Redis Cache` as the `serviceName`.

## Query Pattern

### Basic {Size} (e.g., C1) — Single node, no HA

ServiceName: Redis Cache
ProductName: Azure Redis Cache Basic
MeterName: {Size} Cache
PriceType: Consumption

**Example meterName values:** `C0 Cache`, `C1 Cache`, `C2 Cache`, `C3 Cache`, `C4 Cache`, `C5 Cache`, `C6 Cache`

### Standard {Size} (e.g., C1) — Full cluster with HA (2 nodes)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Standard
MeterName: {Size} Cache
PriceType: Consumption

**Example meterName values:** `C0 Cache`, `C1 Cache`, `C2 Cache`, `C3 Cache`, `C4 Cache`, `C5 Cache`, `C6 Cache`

> Use `{Size} Cache` (NOT `{Size} Cache Instance`) to get the **total cluster cost** matching the Azure Portal.

### Premium {Size} (e.g., P1) — Full cluster with HA (2 nodes)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Premium
MeterName: {Size} Cache
PriceType: Consumption

**Example meterName values:** `P1 Cache`, `P2 Cache`, `P3 Cache`, `P4 Cache`, `P5 Cache`

> Use `{Size} Cache` (NOT `{Size} Cache Instance`) to get the **total cluster cost** matching the Azure Portal.

### Premium {Size} — Per-node pricing (for scaling calculations)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Premium
MeterName: {Size} Cache Instance
PriceType: Consumption

**Example meterName values:** `P1 Cache Instance`, `P2 Cache Instance`, `P3 Cache Instance`, `P4 Cache Instance`, `P5 Cache Instance`

> Use this only when calculating costs for **sharded clusters** where you need per-node cost × shard count.

## Product Names

| Tier             | productName                          | skuName examples                                        | Notes                               |
| ---------------- | ------------------------------------ | ------------------------------------------------------- | ----------------------------------- |
| Basic            | `Azure Redis Cache Basic`            | `C0`–`C6`                                               | No HA, no replication               |
| Standard         | `Azure Redis Cache Standard`         | `C0`–`C6`                                               | HA with replication                 |
| Premium          | `Azure Redis Cache Premium`          | `P1`–`P5`                                               | Clustering, persistence, VNet       |
| Enterprise       | `Azure Redis Cache Enterprise`       | `E1`, `E5`, `E10`, `E20`, `E50`, `E100`, `E200`, `E400` | Redis Stack, active geo-replication |
| Enterprise Flash | `Azure Redis Cache Enterprise Flash` | `F300`, `F700`, `F1500`                                 | Flash-optimized, large datasets     |

## Cost Formula

```
Monthly = retailPrice × 730 hours × shardCount × (1 + replicas)
```

## Reserved Instance Pricing

RIs available for **Premium only** (P1-P5). Returns both 1-Year and 3-Year terms. Divide `retailPrice` by 12 (1-Year) or 36 (3-Year) for monthly cost.

### RI for Premium — substitute {Size} with P1-P5

ServiceName: Redis Cache
MeterName: {Size} Cache Instance
PriceType: Reservation

**Example meterName values:** `P1 Cache Instance`, `P2 Cache Instance`, `P3 Cache Instance`, `P4 Cache Instance`, `P5 Cache Instance`

> **Important:** RI pricing uses `{Size} Cache Instance` (per-node), not `{Size} Cache`. Multiply by 2 for HA cluster cost.

> **RI MonthlyCost trap** — see shared.md & Reserved Instance MonthlyCost.

## Notes

- Basic tier has no SLA or replication — dev/test only
- Standard tier includes replication (2 nodes)
- Enterprise tiers use Redis Stack modules (RediSearch, RedisJSON, etc.)
- Use `ProductName` to disambiguate tiers sharing the same meter names
