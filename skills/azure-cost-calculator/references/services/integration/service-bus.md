---
serviceName: Service Bus
category: integration
aliases: [ASB, Queues, Topics]
primaryCost: "Namespace hours (Standard/Premium) + operations (Basic/Standard)"
hasFreeGrant: true
privateEndpoint: true
---

# Service Bus

> **Trap (unfiltered query)**: Querying without `MeterName` returns multiple meters (Base Unit + Operations + Relay Hours). The `summary.totalMonthlyCost` sums all, inflating the estimate. Always filter by `MeterName`.

> **Trap (Premium operations)**: Premium Messaging Units include operations at no extra charge — do NOT add an operations cost line for Premium tier.

> **Trap (Basic tier)**: Basic tier has NO hourly namespace charge — it is operations-only pricing (per 1M operations).

## Query Pattern

### Basic tier — operations only (per 1M)

ServiceName: Service Bus
SkuName: Basic
MeterName: Basic Messaging Operations

### Standard tier — namespace base unit (hourly)

ServiceName: Service Bus
SkuName: Standard
MeterName: Standard Base Unit

### Standard tier — operations (per 1M, first 13M included)

ServiceName: Service Bus
SkuName: Standard
MeterName: Standard Messaging Operations

### Premium — messaging unit (InstanceCount for multi-unit)

ServiceName: Service Bus
SkuName: Premium
MeterName: Premium Messaging Unit
InstanceCount: 2

## Meter Names

| Meter                              | SKU                  | unitOfMeasure | Purpose                                      |
| ---------------------------------- | -------------------- | ------------- | -------------------------------------------- |
| `Basic Messaging Operations`       | `Basic`              | `1M`          | Per 1M operations                            |
| `Standard Base Unit`               | `Standard`           | `1/Hour`      | Namespace hourly charge                      |
| `Standard Messaging Operations`    | `Standard`           | `1M`          | Per 1M operations (first 13M included)       |
| `Hybrid Connections Listener Unit` | `Hybrid Connections` | `1 Hour`      | Per listener hourly charge                   |
| `Premium Messaging Unit`           | `Premium`            | `1/Hour`      | Messaging Unit (hourly, operations included) |

## Cost Formula

```
Basic:    Monthly = operations / 1M × price_per_1M
Standard: Monthly = baseUnit_hourly × 730 + max(0, operations − 13M) / 1M × ops_price + [relay_hourly × 730 × relayCount]
Premium:  Monthly = MU_hourly × 730 × muCount (operations included)
```

## Notes

- Basic tier: queues and topics only, no sessions, no duplicate detection, max 256 KB message
- Standard tier: first 13M operations/month included with Base Unit
- Premium tier: messaging units provide dedicated resources; 1 MU ≈ sustained throughput for most workloads
- **Private Endpoints**: Require Premium tier — not available on Basic or Standard
- `serviceFamily eq 'Integration'` in the API; also includes Hybrid Connections and WCF Relay meters
