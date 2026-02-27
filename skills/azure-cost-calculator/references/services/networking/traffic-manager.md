---
serviceName: Traffic Manager
category: networking
aliases: [DNS Load Balancer]
primaryCost: "Per million DNS queries (tiered) + per health check endpoint per month + add-ons"
pricingRegion: global
---

# Traffic Manager

> **Trap (sub-cent rounding)**: DNS query pricing is per million queries — small volumes produce minimal cost in the script. Use `Quantity` to represent millions of queries (e.g., `Quantity: 10` = 10M queries/month). Use `retailPrice` from query results for each tier.

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

| Parameter     | How to determine             | Example values                                |
| ------------- | ---------------------------- | --------------------------------------------- |
| `serviceName` | Always `Traffic Manager`     | `Traffic Manager`                             |
| `productName` | Single product               | `Traffic Manager`                             |
| `skuName`     | Endpoint type or feature     | `Azure Endpoint`, `Non-Azure Endpoint`        |
| `meterName`   | Billing dimension            | `DNS Queries`, `Azure Endpoint Health Checks` |
| `Region`      | Always `Global` (commercial) | `Global`, `US Gov`                            |

## Meter Names

| Meter                                                   | skuName              | unitOfMeasure | Notes                                  |
| ------------------------------------------------------- | -------------------- | ------------- | -------------------------------------- |
| `DNS Queries`                                           | `Azure Endpoint`     | `1M`          | Tiered: 0–1B at higher rate, 1B+ lower |
| `Azure Endpoint Health Checks`                          | `Azure Endpoint`     | `1`           | Per endpoint per month                 |
| `Azure Endpoint Fast Interval Health Check Add-ons`     | `Azure Endpoint`     | `1`           | 10s interval add-on per endpoint       |
| `Non-Azure Endpoint Health Checks`                      | `Non-Azure Endpoint` | `1`           | Per endpoint per month                 |
| `Non-Azure Endpoint Fast Interval Health Check Add-ons` | `Non-Azure Endpoint` | `1`           | 10s interval add-on per endpoint       |
| `Azure Region Real User Measurements`                   | `Azure Region`       | `1M`          | Free (retailPrice = 0)                 |
| `Non-Azure Region Real User Measurements`               | `Non-Azure Region`   | `1M`          | Free (retailPrice = 0)                 |
| `Traffic View Data Points Processed`                    | `Traffic View`       | `1M`          | Per million data points                |

> **Trap (tiered DNS)**: DNS query pricing returns two rows with different `tierMinimumUnits` (0 and 1000, i.e. 0–1B and >1B queries). The script sums both tiers — ignore `totalMonthlyCost` and manually calculate using tier boundaries.

## Cost Formula

```
DNS         = dnsPrice_tier1 × queriesInMillions                      (if ≤ 1000, i.e. ≤ 1B queries)
            = (dnsPrice_tier1 × 1000)                                 (first 1B queries)
              + dnsPrice_tier2 × (queriesInMillions - 1000)           (above 1B, if > 1000)
HealthCheck = healthCheckPrice × endpointCount
FastInterval = fastIntervalPrice × endpointCount  (if enabled)
TrafficView = trafficViewPrice × dataPointsInMillions
Monthly     = DNS + HealthCheck + FastInterval + TrafficView
```

## Notes

- **Real User Measurements**: Free (retailPrice = 0)
- **Fast Interval**: Reduces health check interval from 30s to 10s at additional per-endpoint cost
- **Capacity planning**: 5 Azure endpoints + 10M DNS queries/month — use `retailPrice` from query results to calculate totals
