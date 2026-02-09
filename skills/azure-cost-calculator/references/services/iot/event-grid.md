---
serviceName: Event Grid
category: iot
aliases: [Event Routing, Event-driven]
---

# Azure Event Grid

**Primary cost**: Per-operation pricing (per 100K or per 1M) + optional MQTT throughput units (hourly)

> **Trap (unfiltered query)**: Querying `-ServiceName 'Event Grid'` without `-MeterName` returns **seven** rows — four distinct meters, three of which have both a free-tier row ($0.00) and a paid-tier row. The `summary.totalMonthlyCost` sums all rows, inflating the estimate. Always filter with `-MeterName` for precise costs.

> **Trap (tiered free grant)**: Operations meters have a free tier (tierMinimumUnits = 0, retailPrice = $0.00) and a paid tier (tierMinimumUnits = 1). The script returns both rows. Use the paid-tier row for cost estimation — the free grant covers the first 100K operations/month.

## Query Pattern

```powershell
# Standard operations — event delivery (per 100K), 10 units = 1M operations
.\Get-AzurePricing.ps1 `
    -ServiceName 'Event Grid' `
    -MeterName 'Standard Operations' `
    -Quantity 10
```

```powershell
# Namespace topic event operations (per 1M events)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Event Grid' `
    -MeterName 'Standard Event Operations' `
    -Quantity 5
```

```powershell
# MQTT messaging operations (per 1M)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Event Grid' `
    -MeterName 'Standard MQTT Operations' `
    -Quantity 5
```

```powershell
# MQTT throughput unit (hourly, for namespace topics)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Event Grid' `
    -MeterName 'Standard Throughput Unit'
```

## Key Fields

| Parameter     | How to determine                    | Example values                                                       |
| ------------- | ----------------------------------- | -------------------------------------------------------------------- |
| `serviceName` | Always `Event Grid`                 | `Event Grid`                                                         |
| `productName` | Single product                      | `Event Grid`                                                         |
| `skuName`     | Always `Standard`                   | `Standard`                                                           |
| `meterName`   | Billing dimension                   | `Standard Operations`, `Standard Event Operations`, `Standard MQTT Operations`, `Standard Throughput Unit` |

## Meter Names

| Meter                        | unitOfMeasure | Notes                                          |
| ---------------------------- | ------------- | ---------------------------------------------- |
| `Standard Operations`        | 100K          | Event delivery operations (custom topics, system topics, domains) |
| `Standard Event Operations`  | 1M            | Namespace topic publish/delivery operations     |
| `Standard MQTT Operations`   | 1M            | MQTT broker messaging operations                |
| `Standard Throughput Unit`   | 1 Hour        | Namespace topic throughput capacity (hourly)    |

## Cost Formula

```
Operations monthly     = (operations / 100K) × retailPrice        (first 100K/month free)
Event Ops monthly      = (events / 1M) × retailPrice              (first 100K events/month free)
MQTT Ops monthly       = (mqttMessages / 1M) × retailPrice        (first 100K messages/month free)
Throughput monthly     = retailPrice × 730 × unitCount
Total                  = Operations + Event Ops + MQTT Ops + Throughput (as applicable)
```

## Notes

- Event Grid has three operation types: Standard Operations (custom/system topics), Event Operations (namespace topics), and MQTT Operations (MQTT broker)
- First 100,000 operations per month are free for each operation type
- Standard Operations are priced per 100K; Event Operations and MQTT Operations are priced per 1M
- Throughput Units are only needed for namespace topics (MQTT/pull delivery) — not required for push-based event subscriptions
- No reserved instance pricing — `-PriceType Reservation` returns 0 results
- All meters use a single productName `Event Grid` and skuName `Standard` — no tier selection needed
