---
serviceName: Azure Monitor
category: monitoring
aliases: [Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive]
primaryCost: "Metric samples + log ingestion/archive/search/export + alerts/notifications per unit"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Monitor

> **Note**: This file covers custom/Prometheus metrics, log-tier meters, alerts, and notifications billed under `ServiceName: Azure Monitor` and `ProductName: Azure Monitor`. For `ServiceName: Log Analytics` meters (Analytics Logs ingestion/retention), see `log-analytics.md`. For Application Insights, see `application-insights.md`.

> **Trap**: Platform metrics (CPU, memory, network, etc.) emitted by Azure resources are **free**; do not include them in cost estimates. Only custom metrics and Prometheus (Azure Monitor workspace) metrics are billable.

> **Trap (Data Restore minimum)**: Data Restore has a minimum of 2 TB and 12-hour duration; even restoring 1 GB incurs the 2 TB minimum charge.

> **Trap (mixed units)**: Azure Monitor meters use `10M`, `1 GB`, `1 GB/Month`, `1 GB/Day`, `1/Day`, `1/Month`, `1K`, and `1` units. For tiered/sub-cent meters, read `unitPrice` and `tierMinimumUnits`; do not use summed totals.

## Query Pattern

### Basic Logs ingestion

ServiceName: Azure Monitor
ProductName: Azure Monitor
SkuName: Basic Logs
MeterName: Basic Logs Data Ingestion
Quantity: 50

### Metrics / Azure Monitor workspace ingestion

ServiceName: Azure Monitor
ProductName: Azure Monitor
SkuName: Metrics ingestion
MeterName: Metrics ingestion Metric samples

### Advanced platform metrics ingestion

ServiceName: Azure Monitor
ProductName: Azure Monitor
SkuName: Advanced Platform Metric Samples Ingested
MeterName: Advanced Platform Metric Samples Ingested Metric samples

### Prometheus metrics queries

ServiceName: Azure Monitor
ProductName: Azure Monitor
SkuName: Prometheus Metrics Queries
MeterName: Prometheus Metrics Queries Metric samples

### Commitment tier (100 GB example)

ServiceName: Azure Monitor
ProductName: Azure Monitor
SkuName: 100 GB Commitment Tier
MeterName: 100 GB Commitment Tier Capacity Reservation

> **Note**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost.

## Meter Names

All listed meters use `ServiceName: Azure Monitor` and `ProductName: Azure Monitor`.

| Meter                                                      | skuName                                     | unitOfMeasure | Notes                                               |
| ---------------------------------------------------------- | ------------------------------------------- | ------------- | --------------------------------------------------- |
| `Metrics ingestion Metric samples`                         | `Metrics ingestion`                         | `10M`         | Custom / Prometheus workspace metrics ingestion     |
| `Advanced Platform Metric Samples Ingested Metric samples` | `Advanced Platform Metric Samples Ingested` | `10M`         | Advanced platform metrics ingestion                 |
| `Prometheus Metrics Queries Metric samples`                | `Prometheus Metrics Queries`                | `10M`         | PromQL query cost (sub-cent)                        |
| `Metrics Export Metric Samples Exported`                   | `Metrics Export`                            | `1K`          | Metric data export via DCE (sub-cent)               |
| `Native Metric Queries API Calls`                          | `Native Metric Queries`                     | `1K`          | Tiered: first 1M calls free                         |
| `API Calls Standard API Call`                              | `API Calls`                                 | `1`           | Tiered: first 1M calls free; paid tier is sub-cent  |
| `Basic Logs Data Ingestion`                                | `Basic Logs`                                | `1 GB`        | ~78% cheaper than Analytics; 30-day fixed retention |
| `Auxiliary Logs Data Ingestion`                            | `Auxiliary Logs`                            | `1 GB`        | Cheapest tier; custom tables only                   |
| `Logs Emitted From Cloud Pipeline Data Emitted`            | `Logs Emitted From Cloud Pipeline`          | `1 GB`        | Cloud pipeline log emission                         |
| `Data Archive`                                             | `Data Archive`                              | `1 GB/Month`  | Long-term archive (up to 12 years)                  |
| `Search Queries Scanned`                                   | `Search Queries`                            | `1 GB`        | Query cost for Basic/Auxiliary tables               |
| `Search Jobs Scanned`                                      | `Search Jobs`                               | `1 GB`        | Archive search job cost                             |
| `Data Restore`                                             | `Data Restore`                              | `1 GB/Day`    | Archive restore, minimum 2 TB × 12 hours            |
| `Log Analytics data export Data Exported`                  | `Log Analytics data export`                 | `1 GB`        | Continuous data export                              |
| `Platform Logs Data Processed`                             | `Platform Logs`                             | `1 GB`        | Diagnostic settings → Storage/Event Hub             |
| `Logs Processed GB`                                        | `Logs Processed`                            | `1`           | DCR transformation processing                       |
| `Data Replication Data Replicated`                         | `Data Replication`                          | `1 GB`        | Cross-workspace replication                         |
| `Standard Web Test Execution`                              | `Standard Web Test`                         | `1`           | Availability test execution (sub-cent)              |
| `Alerts Metric Monitored`                                  | `Alerts`                                    | `1/Month`     | Tiered: first 10 signals free                       |
| `Alerts Dynamic Threshold`                                 | `Alerts`                                    | `1/Month`     | Dynamic threshold metric alert signal               |
| `Dynamic Threshold Log Alerts`                             | `Dynamic Threshold Log Alerts`              | `1/Month`     | Dynamic threshold log alert meter                   |
| `Alerts Resource Monitored at {N} Minute Frequency`        | `Alerts`                                    | `1/Month`     | Log search alerts: 1/5/10/15 min frequencies        |
| `Alerts System Log Monitored at {N} Minute Frequency`      | `Alerts`                                    | `1/Month`     | System log alerts: 10× Resource Monitored rate      |
| `Emails`                                                   | `Emails`                                    | `1`           | Tiered: first 1K emails free                        |
| `Notifications ITSM Connector Create/Update Event`         | `Notifications`                             | `1`           | Tiered: first 1K events free                        |
| `Notifications Push Notification`                          | `Notifications`                             | `1`           | Tiered: first 1K notifications free                 |
| `Notifications Secure web hook`                            | `Notifications`                             | `10`          | Tiered: first 100 notifications free                |
| `Notifications Web hook`                                   | `Notifications`                             | `10`          | Tiered: first 10K notifications free                |
| `{N} GB Commitment Tier Capacity Reservation`              | `{N} GB Commitment Tier`                    | `1/Day`       | Volume discounts (100–50000 GB/day)                 |

> **Note**: SMS and voice also bill under Azure Monitor. Query `SMS Country Code {N} Notification` or `Voice Calls Voice Call Country Code {N}` for country-specific rates.

## Cost Formula

```
Metrics        = samples / 10M × retailPrice (per metric SKU)
Log Ingestion  = ingestedGB × retailPrice (per log tier: Basic, Auxiliary, Cloud Pipeline)
Archive        = archiveGB × retailPrice (per GB/month)
Search         = scannedGB × retailPrice (per query/job)
Restore        = max(restoredGB × days, 2048 × 0.5) × retailPrice
Alerts         = max(0, metricSignals - 10) × retailPrice + logAlertRules × frequency_retailPrice
Notifications  = max(0, events - freeGrant) / unitSize × retailPrice
Commitment     = retailPrice × 30 (unit is 1/Day)
```

## Notes

- **Prometheus / AMW**: Ingestion and query meters are billable; `Metric Samples Processed` no longer appears in the live API
- **Basic Logs**: Search-only (no alerts/dashboards); 30-day retention. **Auxiliary Logs**: cheapest tier; custom tables only via Logs Ingestion API
- **Sentinel-enabled workspaces**: Basic Logs ingestion uses Sentinel meters; Auxiliary Logs remain under Azure Monitor
- **Data Restore**: Minimum 2 TB × 12-hour duration; plan restores carefully
- Commitment tiers (100–50000 GB/day) provide volume discounts; overage billed at effective rate
- Alerts: metric alerts (first 10 signals free), log search alerts priced by evaluation frequency, dynamic thresholds priced per signal
- Notifications/API calls: tiered free grants and sub-cent paid tiers require `tierMinimumUnits` handling
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
