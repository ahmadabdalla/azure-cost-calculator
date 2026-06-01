---
serviceName: Redis Cache
category: databases
aliases: [Azure Cache for Redis, Redis, Azure Redis, Managed Redis]
billingConsiderations: [Reserved Instances]
primaryCost: "Cache instance hours based on tier and size × 730 × shardCount"
privateEndpoint: true
---

# Azure Cache for Redis

> **Trap (duplicate meters)**: Standard and Premium tiers return **two meters per size**, e.g., `C1 Cache` AND `C1 Cache Instance`. The `{Size} Cache` meter is the **total cluster cost** (2 nodes with HA); `{Size} Cache Instance` is exactly **half** (per-node). **Use `{Size} Cache` for total cost matching the Azure Portal.** Basic, Enterprise, and Enterprise Flash tiers only have `{Size} Cache` (no `Cache Instance` variant). Always include `ProductName` to filter by tier.

> **Trap (Premium P1 ambiguity)**: Querying `meterName eq 'P1 Cache Instance'` returns **multiple results**: Consumption pricing (per-node hourly) AND Reservation pricing (1-Year/3-Year). Always filter with `type eq 'Consumption'` or `priceType eq 'Consumption'` to get deterministic results.

> **Note**: The Azure Portal calls this "Azure Cache for Redis" but the Retail Prices API uses `Redis Cache` as the `serviceName`.

## Query Pattern

### Basic {Size} (e.g., C1): Single node, no HA

ServiceName: Redis Cache
ProductName: Azure Redis Cache Basic
MeterName: {Size} Cache
PriceType: Consumption

### Standard {Size} (e.g., C1): Full cluster with HA (2 nodes)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Standard
MeterName: {Size} Cache
PriceType: Consumption

### Premium {Size} (e.g., P1): Full cluster with HA (2 nodes)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Premium
MeterName: {Size} Cache
PriceType: Consumption

### Premium {Size}: Per-node pricing (for sharded cluster calculations)

ServiceName: Redis Cache
ProductName: Azure Redis Cache Premium
MeterName: {Size} Cache Instance
PriceType: Consumption
InstanceCount: 3 # number of shards in cluster

## Key Fields

| Parameter     | How to determine                  | Example values                                              |
| ------------- | --------------------------------- | ----------------------------------------------------------- |
| `serviceName` | Always `Redis Cache`              | `Redis Cache`                                               |
| `productName` | Tier selection                    | `Azure Redis Cache Basic`, `Standard`, `Premium`            |
| `skuName`     | Cache size                        | `C0`–`C6`, `P1`–`P5`, `E1`–`E400`, `F300`–`F1500`         |
| `meterName`   | Size + meter type                 | `C1 Cache`, `P1 Cache Instance`, `E10 Cache`, `F700 Cache` |

## Meter Names

| Meter pattern        | unitOfMeasure | Tiers                        | Notes                                    |
| -------------------- | ------------- | ---------------------------- | ---------------------------------------- |
| `{Size} Cache`       | `1 Hour`      | Basic, Standard, Premium, Enterprise, Enterprise Flash | Total cluster cost (includes HA nodes)  |
| `{Size} Cache Instance` | `1 Hour`  | Standard, Premium only       | Per-node cost (half of `{Size} Cache`)   |

## Cost Formula

```
Using {Size} Cache (total):    Monthly = retailPrice × 730 × cacheCount
Using {Size} Cache Instance:   Monthly = retailPrice × 730 × shardCount × nodesPerShard
```

## Notes

- Basic tier has no SLA or replication (dev/test only); use `ProductName` to disambiguate tiers
- Standard tier includes replication (2 nodes); Enterprise tiers use Redis Stack modules (RediSearch, RedisJSON, etc.)
- Private Endpoint requires Premium tier or higher (not available on Basic/Standard); see `networking/private-link.md` for PE pricing

## Reserved Instance Pricing

RIs available for **Premium** (P1-P5), **Enterprise** (E1, E10, E20, E50, E100 only — not E5/E200/E400), **Enterprise Flash**, and **Azure Managed Redis** tiers. Divide `retailPrice` by 12 (1-Year) or 36 (3-Year) for monthly cost.

### RI for Premium: substitute {Size} with P1-P5

ServiceName: Redis Cache
MeterName: {Size} Cache Instance
PriceType: Reservation

> **Note**: RI pricing uses `{Size} Cache Instance` (per-node), not `{Size} Cache`. Multiply by 2 for HA cluster cost.

## Product Names

| Tier             | productName                          | skuName examples                                         |
| ---------------- | ------------------------------------ | -------------------------------------------------------- |
| Basic            | `Azure Redis Cache Basic`            | `C0`–`C6`                                                |
| Standard         | `Azure Redis Cache Standard`         | `C0`–`C6`                                                |
| Premium          | `Azure Redis Cache Premium`          | `P1`–`P5`                                                |
| Enterprise       | `Azure Redis Cache Enterprise`       | `E1`, `E5`, `E10`, `E20`, `E50`, `E100`, `E200`, `E400` |
| Enterprise Flash | `Azure Redis Cache Enterprise Flash` | `F300`, `F700`, `F1500`                                  |
| Managed Redis    | `Azure Managed Redis - {tier}`       | Balanced, Memory/Compute/Flash Optimized                 |
