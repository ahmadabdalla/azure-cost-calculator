---
serviceName: Service Bus
category: integration
aliases: [ASB, Queues, Topics]
primaryCost: "Hourly base charge (Standard/Premium) + operations + brokered connections (Standard)"
hasFreeGrant: true
privateEndpoint: true
---

# Service Bus

> **Trap (unfiltered query)**: Querying without `MeterName` returns multiple meters (Base Unit + Operations + Brokered Connections + Relay Hours). The `summary.totalMonthlyCost` sums all, inflating the estimate. Always filter by `MeterName`.

> **Trap (Standard Base Unit)**: Returns two rows with different `unitOfMeasure` — `1/Hour` and `1/Month`. Use the hourly rate × 730 for prorated billing. The base charge applies once per Azure subscription, not per namespace.

> **Trap (Premium operations)**: Premium Messaging Units include operations and brokered connections at no extra charge; do NOT add separate operations or connection cost lines for Premium tier.

> **Trap (Basic tier)**: Basic tier has NO hourly namespace charge; it is operations-only pricing (per 1M operations).

## Query Pattern

### Basic tier: operations only (per 1M)

ServiceName: Service Bus
SkuName: Basic
MeterName: Basic Messaging Operations

### Standard tier: namespace base unit (hourly)

ServiceName: Service Bus
SkuName: Standard
MeterName: Standard Base Unit

### Standard tier: operations (per 1M, tiered — first 13M included)

ServiceName: Service Bus
SkuName: Standard
MeterName: Standard Messaging Operations

### Standard tier: brokered connections (tiered — first 1,000 included)

ServiceName: Service Bus
SkuName: Standard
MeterName: Standard Brokered Connection

### Premium: messaging unit (InstanceCount for multi-unit)

ServiceName: Service Bus
SkuName: Premium
MeterName: Premium Messaging Unit
InstanceCount: 2

## Meter Names

| Meter                              | SKU                        | unitOfMeasure | Purpose                                                  |
| ---------------------------------- | -------------------------- | ------------- | -------------------------------------------------------- |
| `Basic Messaging Operations`       | `Basic`                    | `1M`          | Per 1M operations                                        |
| `Standard Base Unit`               | `Standard`                 | `1/Hour`      | Hourly base charge, per subscription (also returns `1/Month` variant) |
| `Standard Messaging Operations`    | `Standard`                 | `1M`          | Per 1M operations; tiered (first 13M included)           |
| `Standard Brokered Connection`     | `Standard`                 | `1`           | Per connection/month; tiered (first 1,000 included)      |
| `Hybrid Connections Listener Unit` | `Hybrid Connections`       | `1 Hour`      | Per listener hourly charge                               |
| `Hybrid Connections Data Transfer` | `Hybrid Connections`       | `1 GB`        | Tiered: first 5 GB free, then per-GB overage             |
| `Premium Messaging Unit`           | `Premium`                  | `1/Hour`      | Messaging Unit (hourly, operations included)             |
| `Geo Replication Zone 1 Data Transfer` | `Geo Replication Zone 1` | `1 GB`    | Premium geo-DR replication (NA/Europe)                    |
| `Geo Replication Zone 2 Data Transfer` | `Geo Replication Zone 2` | `1 GB`    | Premium geo-DR replication (Asia-Pacific)                 |
| `Geo Replication Zone 3 Data Transfer` | `Geo Replication Zone 3` | `1 GB`    | Premium geo-DR replication (Brazil/other)                 |
| `WCF Relay`                        | `WCF Relay`                | `100 Hours`   | Legacy relay; per 100 hours (divide by 100 for hourly)   |
| `WCF Relay Message`               | `WCF Relay`                | `10K`         | Legacy relay; per 10K messages                           |

## Cost Formula

```
Basic:    Monthly = operations / 1M × ops_price
Standard: Monthly = baseUnit_hourly × 730
         + max(0, operations − 13M) / 1M × tiered_ops_price
         + max(0, connections − 1,000) × tiered_connection_price
Premium:  Monthly = MU_hourly × 730 × muCount (operations + connections included)
```

## Notes

- Basic tier: queues and topics only, no sessions, no duplicate detection, max 256 KB message
- Standard tier: first 13M operations/month and first 1,000 brokered connections/month included
- Standard base charge is billed once per Azure subscription, not per namespace
- Standard operations and brokered connections use tiered pricing; calculate each tier progressively
- Premium tier: 1, 2, 4, 8, or 16 messaging units per namespace; provides dedicated resources
- Geo Replication (Premium only): adds per-GB data transfer cost by zone (Zone 1/2/3 at different rates)
- **Private Endpoints**: Require Premium tier. Not available on Basic or Standard
- WCF Relay uses non-standard units (`100 Hours`, `10K`); divide prices accordingly for per-hour/per-message rates
