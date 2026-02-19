---
serviceName: Event Grid
category: iot
aliases: [Event Routing, Event-driven]
primaryCost: "Per-operation pricing (per 100K or per 1M) + optional MQTT throughput units (hourly)"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Event Grid

> **Trap (unfiltered query)**: Querying with `ServiceName Event Grid` without `MeterName` returns **seven** rows — four distinct meters, three of which have both a free-tier row (zero price) and a paid-tier row. The `summary.totalMonthlyCost` sums all rows, inflating the estimate. Always filter with `MeterName` for precise costs.

> **Trap (tiered free grant)**: Operations meters have a free tier (tierMinimumUnits = 0, zero retailPrice) and a paid tier (tierMinimumUnits = 1). The script returns both rows and `totalMonthlyCost` does not subtract the free grant. Ignore `summary.totalMonthlyCost` — manually calculate billable units as `max(0, totalOps - 100K)` using the paid-tier `retailPrice`.

## Query Pattern

### Standard operations — event delivery (per 100K), 10 units = 1M operations

ServiceName: Event Grid
MeterName: Standard Operations
Quantity: 10

### Namespace topic event operations (per 1M events)

ServiceName: Event Grid
MeterName: Standard Event Operations
Quantity: 5

### MQTT messaging operations (per 1M)

ServiceName: Event Grid
MeterName: Standard MQTT Operations
Quantity: 5

### MQTT throughput unit (hourly, for namespace topics)

ServiceName: Event Grid
MeterName: Standard Throughput Unit

## Key Fields

| Parameter     | How to determine    | Example values                                                                                             |
| ------------- | ------------------- | ---------------------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Event Grid` | `Event Grid`                                                                                               |
| `productName` | Single product      | `Event Grid`                                                                                               |
| `skuName`     | Always `Standard`   | `Standard`                                                                                                 |
| `meterName`   | Billing dimension   | `Standard Operations`, `Standard Event Operations`, `Standard MQTT Operations`, `Standard Throughput Unit` |

## Meter Names

| Meter                       | unitOfMeasure | Notes                                                             |
| --------------------------- | ------------- | ----------------------------------------------------------------- |
| `Standard Operations`       | 100K          | Event delivery operations (custom topics, system topics, domains) |
| `Standard Event Operations` | 1M            | Namespace topic publish/delivery operations                       |
| `Standard MQTT Operations`  | 1M            | MQTT broker messaging operations                                  |
| `Standard Throughput Unit`  | 1 Hour        | Namespace topic throughput capacity (hourly)                      |

## Cost Formula

```
billableOps            = max(0, operations   - 100K)
billableEventOps       = max(0, events       - 100K)
billableMqttOps        = max(0, mqttMessages - 100K)

Operations monthly     = (billableOps      / 100K) × retailPrice
Event Ops monthly      = (billableEventOps / 1M)   × retailPrice
MQTT Ops monthly       = (billableMqttOps  / 1M)   × retailPrice
Throughput monthly     = retailPrice × 730 × unitCount
Total                  = Operations + Event Ops + MQTT Ops + Throughput (as applicable)
```

## Notes

- Event Grid has three operation types: Standard Operations (custom/system topics, partner topics, domains — push delivery), Event Operations (namespace topics — push/pull delivery), and MQTT Operations (MQTT broker)
- First 100,000 operations per month are free for each operation type (manual deduction — see trap)
- Standard Operations are priced per 100K; Event Operations and MQTT Operations are priced per 1M
- Topic type does not affect meter choice: system, custom, partner topics and domains all use `Standard Operations`; namespace topics use `Standard Event Operations`
- Throughput Units are only needed for namespace topics (MQTT/pull delivery) — not required for push-based event subscriptions
- All meters use a single productName `Event Grid` and skuName `Standard` — no tier selection needed
- Supports private endpoints — see `networking/private-link.md` for PE and DNS zone pricing
