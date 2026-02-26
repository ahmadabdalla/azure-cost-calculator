---
serviceName: Event Hubs
category: iot
aliases: [Kafka on Azure, Event Streaming]
primaryCost: "Throughput/Processing Units (hourly) + ingress events (per million) + optional Capture and Kafka add-ons"
privateEndpoint: true
---

# Azure Event Hubs

> **Trap (Standard unfiltered)**: Querying with `SkuName Standard` without `MeterName` returns **four** meters: Throughput Unit, Ingress Events, Capture, and Kafka Endpoint. The `summary.totalMonthlyCost` sums all four, inflating the estimate ~7×. Always filter with `MeterName Standard Throughput Unit` for the base cost.

> **Trap (Ingress Events unit)**: Ingress Events is priced per **1M events** (`UnitOfMeasure: "1M"`). The default `MonthlyCost` assumes quantity 1 = 1 million events. Use `Quantity` with the number of millions of events expected.

## Query Pattern

### Standard tier — throughput unit (base cost)

ServiceName: Event Hubs
SkuName: Standard
MeterName: Standard Throughput Unit

### Standard tier — ingress events (per 1M events)

ServiceName: Event Hubs
SkuName: Standard
MeterName: Standard Ingress Events
Quantity: 10

### Premium tier — 3 processing units (use InstanceCount for multi-unit)

ServiceName: Event Hubs
SkuName: Premium
MeterName: Premium Processing Unit
InstanceCount: 3

### Dedicated tier — capacity unit

ServiceName: Event Hubs
SkuName: Dedicated
MeterName: Dedicated Capacity Unit

> For Basic tier, substitute `Basic` in SkuName and MeterName (e.g., `Basic Throughput Unit`, `Basic Ingress Events`).

## Meter Names

| Meter                                  | SKU                    | Purpose                                |
| -------------------------------------- | ---------------------- | -------------------------------------- |
| `Basic Throughput Unit`                | Basic                  | Throughput unit (hourly)               |
| `Basic Ingress Events`                 | Basic                  | Ingress events (per 1M)                |
| `Standard Throughput Unit`             | Standard               | Throughput unit (hourly)               |
| `Standard Ingress Events`              | Standard               | Ingress events (per 1M)                |
| `Standard Capture`                     | Standard               | Event capture to storage (hourly)      |
| `Standard Kafka Endpoint`              | Standard               | Kafka protocol support (hourly)        |
| `Premium Processing Unit`              | Premium                | Processing unit (hourly)               |
| `Premium Extended Retention`           | Premium                | Extended retention (per GB/month)      |
| `Dedicated Capacity Unit`              | Dedicated              | Capacity unit (hourly)                 |
| `Dedicated Extended Retention`         | Dedicated              | Extended retention (per GB/month)      |
| `Geo Replication Zone 1 Data Transfer` | Geo Replication Zone 1 | Geo-replication data transfer (per GB) |

## Cost Formula

```
Standard monthly = TU_hourly × 730 × tuCount + (ingressEvents_per1M × millions) + [Capture_hourly × 730] + [Kafka_hourly × 730]
Premium monthly  = PU_hourly × 730 × puCount + [ExtRetention_perGB × GB]
Dedicated monthly = CU_hourly × 730 × cuCount + [ExtRetention_perGB × GB]
Geo-DR monthly   = 2 × Premium namespace cost + geoReplication_perGB × transferredGB
```

## Notes

- Basic tier: no Capture, no Kafka endpoint, limited features
- Standard tier: Capture and Kafka are optional per-namespace flat charges (not per-TU)
- Standard tier: max 7-day retention; no extended retention meter available
- Premium/Dedicated include ingress events at no extra charge
- Capacity: 1 TU = 1 MB/s ingress / ~1K events/s; 1 PU ≈ 5–10 MB/s; 1 CU ≈ 20 MB/s
- Geo-DR requires two separate Premium/Dedicated namespaces — budget 2× namespace cost plus replication transfer
- All throughput/processing/capacity units are billed hourly — use 730 hours/month
- Event Hubs is under `serviceFamily eq 'Internet of Things'` in the API
- Private endpoints require Standard tier or higher
