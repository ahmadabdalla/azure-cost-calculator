---
serviceName: Redis Cache
category: databases
aliases: [Azure Cache for Redis, Redis, Azure Redis, Managed Redis]
billingConsiderations: [Reserved Instances]
primaryCost: "Cache instance hours based on tier and size × 730 × shardCount"
privateEndpoint: true
---

# Redis Cache

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

### Premium {Size} (e.g., P1) — Full cluster with HA (2 nodes)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Premium
MeterName: {Size} Cache
PriceType: Consumption

**Example meterName values:** `P1 Cache`, `P2 Cache`, `P3 Cache`, `P4 Cache`, `P5 Cache`

### Premium {Size} — Per-node pricing (for sharded cluster calculations)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Premium
MeterName: {Size} Cache Instance
PriceType: Consumption
InstanceCount: 3 # number of shards in cluster

**Example meterName values:** `P1 Cache Instance`, `P2 Cache Instance`, `P3 Cache Instance`, `P4 Cache Instance`, `P5 Cache Instance`

## Cost Formula

```
Monthly = retailPrice × 730 hours × shardCount × (1 + replicas)
```

## Notes

- Basic tier has no SLA or replication (dev/test only); use `ProductName` to disambiguate tiers
- Standard tier includes replication (2 nodes); Enterprise tiers use Redis Stack modules (RediSearch, RedisJSON, etc.)
- Azure Managed Redis (Balanced, Memory Optimized, Compute Optimized, Flash Optimized) is the successor product — uses `Azure Managed Redis - {tier}` productName with `{Size} Cache Instance` meters only

## Reserved Instance Pricing

RIs available for **Premium** (P1-P5), **Enterprise** (select SKUs), **Enterprise Flash**, and **Azure Managed Redis** tiers. Returns 1-Year and 3-Year terms. Divide `retailPrice` by 12 (1-Year) or 36 (3-Year) for monthly cost.

### RI for Premium — substitute {Size} with P1-P5

ServiceName: Redis Cache
MeterName: {Size} Cache Instance
PriceType: Reservation

**Example meterName values:** `P1 Cache Instance`, `P2 Cache Instance`, `P3 Cache Instance`, `P4 Cache Instance`, `P5 Cache Instance`

> **Important:** RI pricing uses `{Size} Cache Instance` (per-node), not `{Size} Cache`. Multiply by 2 for HA cluster cost.

## Product Names

| Tier             | productName                          | skuName examples                                        | Notes                               |
| ---------------- | ------------------------------------ | ------------------------------------------------------- | ----------------------------------- |
| Basic            | `Azure Redis Cache Basic`            | `C0`–`C6`                                               | No HA, no replication               |
| Standard         | `Azure Redis Cache Standard`         | `C0`–`C6`                                               | HA with replication                 |
| Premium          | `Azure Redis Cache Premium`          | `P1`–`P5`                                               | Clustering, persistence, VNet       |
| Enterprise       | `Azure Redis Cache Enterprise`       | `E1`, `E5`, `E10`, `E20`, `E50`, `E100`, `E200`, `E400` | Redis Stack, active geo-replication |
| Enterprise Flash | `Azure Redis Cache Enterprise Flash` | `F300`, `F700`, `F1500`                                 | Flash-optimized, large datasets     |
| Managed Balanced | `Azure Managed Redis - Balanced`       | `B0`–`B1000`                                            | Successor product, 4:1 memory:vCPU  |
| Managed Memory   | `Azure Managed Redis - Memory Optimized` | `M10`–`M2000`                                        | 8:1 memory:vCPU ratio               |
| Managed Compute  | `Azure Managed Redis - Compute Optimized` | `X1`–`X700`                                         | 2:1 memory:vCPU, max throughput     |
| Managed Flash    | `Azure Managed Redis - Flash Optimized` | `A250`–`A4500`                                        | NVMe-backed, very large datasets    |
