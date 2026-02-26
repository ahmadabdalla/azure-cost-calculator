---
serviceName: Azure Monitor
category: monitoring
aliases: [Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive]
primaryCost: "Custom metrics per 10M samples + log-tier ingestion/archive/export per-GB"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Monitor

> **Note**: This file covers custom metrics AND log-tier meters billed under `ServiceName: Azure Monitor`. For `ServiceName: Log Analytics` meters (Analytics Logs ingestion/retention), see `log-analytics.md`. For Application Insights, see `application-insights.md`.

> **Trap**: Platform metrics (CPU, memory, network, etc.) emitted by Azure resources are **free** — do not include them in cost estimates. Only custom metrics published via the Azure Monitor API are billable.

> **Trap (Data Restore minimum)**: Data Restore has a minimum of 2 TB and 12-hour duration — even restoring 1 GB incurs the 2 TB minimum charge.

> **Trap (DCR transformation)**: DCR transformation billing (`Logs Processed`) is NOT YET ACTIVE for Analytics/Basic tables (date TBA). Active for Auxiliary tables since Oct 2025. Sentinel-enabled workspaces are exempt for Analytics tables.

## Query Pattern

### Custom metrics ingestion (preview — billing not yet enabled)

ServiceName: Azure Monitor
SkuName: Metrics ingestion
MeterName: Metrics ingestion Metric samples

### Basic Logs ingestion

ServiceName: Azure Monitor
SkuName: Basic Logs
MeterName: Basic Logs Data Ingestion

### Data Archive

ServiceName: Azure Monitor
SkuName: Data Archive
MeterName: Data Archive

### Commitment tier (100 GB example)

ServiceName: Azure Monitor
SkuName: 100 GB Commitment Tier
MeterName: 100 GB Commitment Tier Capacity Reservation

> **Note**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost.

## Key Fields

| Parameter     | How to determine                           | Example values                                                                             |
| ------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------ |
| `serviceName` | Fixed value                                | `Azure Monitor`                                                                            |
| `skuName`     | Depends on meter category                  | `Basic Logs`, `Auxiliary Logs`, `Data Archive`, `Search Queries`, `100 GB Commitment Tier` |
| `meterName`   | Matches the billing meter for each feature | `Metrics ingestion Metric samples`, `Basic Logs Data Ingestion`, `Data Archive`             |

## Meter Names

| Meter                                         | skuName                     | unitOfMeasure | Notes                                                            |
| --------------------------------------------- | --------------------------- | ------------- | ---------------------------------------------------------------- |
| `Metrics ingestion Metric samples`            | `Metrics ingestion`         | `10M`         | Custom metrics — per 10M samples (preview, not yet billed)       |
| `Basic Logs Data Ingestion`                   | `Basic Logs`                | `1 GB`        | ~78% cheaper than Analytics; search-only, 30-day fixed retention |
| `Auxiliary Logs Data Ingestion`               | `Auxiliary Logs`            | `1 GB`        | Cheapest tier; custom tables only (via Logs Ingestion API)       |
| `Data Archive`                                | `Data Archive`              | `1 GB/Month`  | Long-term retention / archive (up to 12 years)                   |
| `Search Queries Scanned`                      | `Search Queries`            | `1 GB`        | Query cost for Basic/Auxiliary tables                            |
| `Search Jobs Scanned`                         | `Search Jobs`               | `1 GB`        | Archive search job cost                                          |
| `Data Restore`                                | `Data Restore`              | `1 GB/Day`    | Archive restore — minimum 2 TB × 12 hours                        |
| `Log Analytics data export Data Exported`     | `Log Analytics data export` | `1 GB`        | Continuous data export                                           |
| `Platform Logs Data Processed`                | `Platform Logs`             | `1 GB`        | Diagnostic settings → Storage/Event Hub                          |
| `Logs Processed GB`                           | `Logs Processed`            | `1`           | DCR transformation processing                                    |
| `Data Replication Data Replicated`            | `Data Replication`          | `1 GB`        | Cross-workspace replication                                      |
| `{N} GB Commitment Tier Capacity Reservation` | `{N} GB Commitment Tier`    | `1/Day`       | Volume discounts (100–50000 GB/day)                              |

## Cost Formula

```
Custom Metrics  = metricSamples / 10M × retailPrice (preview — not yet billed)
Basic Ingestion = basicGB × retailPrice
Archive Storage = archiveGB × retailPrice (per GB/month)
Search/Restore  = scannedGB × retailPrice (per query/job)
Commitment Tier = retailPrice × 30 (unit is 1/Day)
```

## Notes

- **Platform metrics are free**: All standard resource metrics have no cost
- **Custom metrics**: Ingestion priced at retailPrice per 10M samples (preview — billing not yet enabled)
- **Basic Logs**: ~78% cheaper than Analytics; supports search queries only (no alerts/dashboards); fixed 30-day retention
- **Auxiliary Logs**: Cheapest ingestion tier; custom tables only via Logs Ingestion API
- **Sentinel-enabled workspaces**: Basic Logs ingestion uses **Sentinel meters** (`ServiceName: Sentinel`, `SkuName: Basic Logs`); Auxiliary Logs remain under Azure Monitor in simplified pricing
- **Data Restore**: Minimum 2 TB × 12-hour duration — plan restores carefully
- Commitment tiers (100–50000 GB/day) provide volume discounts; overage billed at effective rate
- Alerts: basic metric alerts (platform metrics) are free; multi-resource/custom metric alerts priced separately
- For Log Analytics workspace ingestion/retention, see `log-analytics.md`; for Application Insights, see `application-insights.md`
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
