---
serviceName: Service Bus
category: integration
aliases: [service bus, messaging, queues, topics]
---

# Service Bus

**Primary cost**: Namespace hours (Standard/Premium) + operations (Basic/Standard)

> **Trap (unfiltered query)**: Querying without `-MeterName` returns multiple meters (Base Unit + Operations + Relay Hours). The `summary.totalMonthlyCost` sums all, inflating the estimate. Always filter by `-MeterName`.

> **Trap (Premium operations)**: Premium Messaging Units include operations at no extra charge — do NOT add an operations cost line for Premium tier.

> **Trap (Basic tier)**: Basic tier has NO hourly namespace charge — it is operations-only pricing (per 1M operations).

## Query Pattern

```powershell
# Basic tier — operations only (per 1M)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Service Bus' `
    -SkuName 'Basic' `
    -MeterName 'Basic Messaging Operations'
```

```powershell
# Standard tier — namespace base unit (hourly)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Service Bus' `
    -SkuName 'Standard' `
    -MeterName 'Standard Base Unit'
```

```powershell
# Standard tier — operations (per 1M, first 13M included)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Service Bus' `
    -SkuName 'Standard' `
    -MeterName 'Standard Messaging Operations'
```

```powershell
# Premium — messaging unit (-InstanceCount for multi-unit)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Service Bus' -SkuName 'Premium' `
    -MeterName 'Premium Messaging Unit' -InstanceCount 2
```

## Meter Names

| Meter                           | SKU      | Purpose                                      |
| ------------------------------- | -------- | -------------------------------------------- |
| `Basic Messaging Operations`    | Basic    | Per 1M operations                            |
| `Standard Base Unit`            | Standard | Namespace hourly charge                      |
| `Standard Messaging Operations` | Standard | Per 1M operations (first 13M included)       |
| `Standard Relay Hours`          | Standard | Hybrid Connections (hourly)                  |
| `Premium Messaging Unit`        | Premium  | Messaging Unit (hourly, operations included) |

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
- Premium supports private endpoints, geo-DR, and partitioned entities
- No reserved instance pricing available for Service Bus
- Service Bus is under `serviceFamily eq 'Integration'` in the API
