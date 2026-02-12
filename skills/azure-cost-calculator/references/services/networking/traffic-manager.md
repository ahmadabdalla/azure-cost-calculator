---
serviceName: Traffic Manager
category: networking
aliases: [DNS Load Balancer]
---

# Azure Traffic Manager

**Primary cost**: Per million DNS queries (tiered) + per health check endpoint per month + optional Fast Failover / Real User Measurements add-ons

> **Trap (sub-cent rounding)**: DNS query pricing is per million queries — small volumes produce `$0.00` in the script. Use `Quantity` to represent millions of queries (e.g., `Quantity: 10` = 10M queries/month). See Known Rates table for published rates.

> **Warning**: **Global-only pricing** — Traffic Manager has no regional pricing. `armRegionName` is `Global` (commercial) or `US Gov`. The default `eastus` region returns zero results. Use `Region: Global` or query the API directly.

## Query Pattern

### DNS queries (Quantity = millions of queries/month)

ServiceName: Traffic Manager
SkuName: Azure Endpoint
MeterName: DNS Queries
Region: Global
Quantity: 10

### Azure endpoint health checks (InstanceCount = number of endpoints)

ServiceName: Traffic Manager
SkuName: Azure Endpoint
MeterName: Azure Endpoint Health Checks
Region: Global
InstanceCount: 5

### Azure endpoint — Fast Interval health check add-on

ServiceName: Traffic Manager
SkuName: Azure Endpoint
MeterName: Azure Endpoint Fast Interval Health Check Add-ons
Region: Global

### Non-Azure endpoint health checks

ServiceName: Traffic Manager
SkuName: Non-Azure Endpoint
MeterName: Non-Azure Endpoint Health Checks
Region: Global

### Direct API (all Global meters)

API: https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Traffic Manager' and armRegionName eq 'Global'
Fields: meterName, skuName, unitPrice, unitOfMeasure, tierMinimumUnits

## Key Fields

| Parameter     | How to determine                        | Example values                             |
| ------------- | --------------------------------------- | ------------------------------------------ |
| `serviceName` | Always `Traffic Manager`                | `Traffic Manager`                          |
| `productName` | Single product                          | `Traffic Manager`                          |
| `skuName`     | Endpoint type or feature                | `Azure Endpoint`, `Non-Azure Endpoint`     |
| `meterName`   | Billing dimension                       | `DNS Queries`, `Azure Endpoint Health Checks` |
| `Region`      | Always `Global` (commercial)            | `Global`, `US Gov`                         |

## Meter Names

| Meter                                                | skuName                | unitOfMeasure | Notes                              |
| ---------------------------------------------------- | ---------------------- | ------------- | ---------------------------------- |
| `DNS Queries`                                        | `Azure Endpoint`       | `1M`          | Tiered: 0–1B at higher rate, 1B+ lower |
| `Azure Endpoint Health Checks`                       | `Azure Endpoint`       | `1`           | Per endpoint per month             |
| `Azure Endpoint Fast Interval Health Check Add-ons`  | `Azure Endpoint`       | `1`           | 10s interval add-on per endpoint   |
| `Non-Azure Endpoint Health Checks`                   | `Non-Azure Endpoint`   | `1`           | Per endpoint per month             |
| `Non-Azure Endpoint Fast Interval Health Check Add-ons` | `Non-Azure Endpoint` | `1`          | 10s interval add-on per endpoint   |
| `Azure Region Real User Measurements`                | `Azure Region`         | `1M`          | Free ($0)                          |
| `Non-Azure Region Real User Measurements`            | `Non-Azure Region`     | `1M`          | Free ($0)                          |
| `Traffic View Data Points Processed`                 | `Traffic View`         | `1M`          | Per million data points            |

> **Trap (tiered DNS)**: DNS query pricing returns two rows with different `tierMinimumUnits` (0 and 1000M). The script sums both tiers — ignore `totalMonthlyCost` and manually calculate using tier boundaries.

## Cost Formula

```
DNS         = dnsPrice_tier1 × queriesInMillions  (first 1000M)
            + dnsPrice_tier2 × (queriesInMillions - 1000)  (above 1000M)
HealthCheck = healthCheckPrice × endpointCount
FastInterval = fastIntervalPrice × endpointCount  (if enabled)
TrafficView = trafficViewPrice × dataPointsInMillions
Monthly     = DNS + HealthCheck + FastInterval + TrafficView
```

## Known Rates
| Meter | Unit | Published Rate (USD) |
| ----- | ---- | -------------------- |
| `DNS Queries` (tier 1, 0–1B) | per 1M | $0.54 |
| `DNS Queries` (tier 2, >1B) | per 1M | $0.375 |

## Notes

- **Real User Measurements**: Free ($0) — **Fast Interval**: Reduces health check interval from 30s to 10s at additional per-endpoint cost
- **Capacity planning**: 5 Azure endpoints + 10M DNS queries/month — use `retailPrice` from query results to calculate totals
- Reserved pricing is not available for Traffic Manager
