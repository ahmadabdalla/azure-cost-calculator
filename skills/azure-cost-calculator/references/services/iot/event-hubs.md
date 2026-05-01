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

### Standard tier: throughput unit (base cost)

ServiceName: Event Hubs
SkuName: Standard
MeterName: Standard Throughput Unit

### Standard tier: ingress events (per 1M events)

ServiceName: Event Hubs
SkuName: Standard
MeterName: Standard Ingress Events
Quantity: 10

### Premium tier: 3 processing units (use InstanceCount for multi-unit)

ServiceName: Event Hubs
SkuName: Premium
MeterName: Premium Processing Unit
InstanceCount: 3

### Dedicated tier: capacity unit

ServiceName: Event Hubs
SkuName: Dedicated
MeterName: Dedicated Capacity Unit

> For Basic tier, substitute `Basic` in SkuName and MeterName (e.g., `Basic Throughput Unit`, `Basic Ingress Events`).

## Meter Names

| Meter | SKU | unitOfMeasure | Purpose |
| ----- | --- | ------------- | ------- |
| `Basic Throughput Unit` | Basic | 1 Hour | Throughput unit |
| `Basic Ingress Events` | Basic | 1M | Ingress events |
| `Standard Throughput Unit` | Standard | 1 Hour | Throughput unit |
| `Standard Ingress Events` | Standard | 1M | Ingress events |
| `Standard Capture` | Standard | 1 Hour | Event capture to storage (flat per-namespace) |
| `Standard Kafka Endpoint` | Standard | 1 Hour | Kafka protocol support (flat per-namespace) |
| `Premium Processing Unit` | Premium | 1 Hour | Processing unit |
| `Premium Extended Retention` | Premium | 1 GB/Month | Retention beyond 1 TB/PU included quota |
| `Dedicated Capacity Unit` | Dedicated | 1 Hour | Capacity unit |
| `Dedicated Extended Retention` | Dedicated | 1 GB/Month | Retention beyond 10 TB/CU included quota |
| `Geo Replication Zone 1 Data Transfer` | Geo Replication Zone 1 | 1 GB | Geo-DR transfer (NA/Europe) |
| `Geo Replication Zone 2 Data Transfer` | Geo Replication Zone 2 | 1 GB | Geo-DR transfer (Asia/Oceania/ME/Africa) |
| `Geo Replication Zone 3 Data Transfer` | Geo Replication Zone 3 | 1 GB | Geo-DR transfer (South America) |

## Cost Formula

```
Standard monthly = TU_hourly × 730 × tuCount + (ingressEvents_per1M × millions) + [Capture_hourly × 730] + [Kafka_hourly × 730]
Premium monthly  = PU_hourly × 730 × puCount + [ExtRetention_perGB × max(0, GB - 1024 × puCount)]
Dedicated monthly = CU_hourly × 730 × cuCount + [ExtRetention_perGB × max(0, GB - 10240 × cuCount)]
Geo-DR monthly   = primary namespace + secondary namespace + geoReplication_perGB × transferredGB
```

## Notes

- Basic tier: no Capture, no Kafka, max 1-day retention
- Standard tier: Capture and Kafka are optional flat per-namespace charges (not per-TU); max 7-day retention
- Premium/Dedicated include ingress events, Kafka, and Schema Registry at no extra charge
- Extended retention: Premium includes 1 TB/PU, Dedicated includes 10 TB/CU before per-GB/month overage
- Capacity: 1 TU = 1 MB/s ingress / ~1K events/s; 1 PU ≈ 5–10 MB/s; 1 CU ≈ 20 MB/s
- Geo-DR needs two Premium/Dedicated namespaces billed independently + replication transfer by zone (Zone 1 NA/Europe, Zone 2 Asia/Pacific, Zone 3 South America)
- All TU/PU/CU meters are billed hourly; use 730 hours/month
- Private endpoints require Standard tier or higher
