---
serviceName: Azure Monitor
category: monitoring
aliases: [Metrics, Alerts, Diagnostics, Platform Metrics, Basic Logs, Auxiliary Logs, Data Archive]
primaryCost: "Log-tier ingestion per-GB + Prometheus metrics per-10M + alerts per-rule/month"
hasFreeGrant: true
privateEndpoint: true
---

# Azure Monitor

> **Note**: This file covers custom/Prometheus metrics, log-tier meters, alerts, and notifications billed under `ServiceName: Azure Monitor`. For `ServiceName: Log Analytics` meters (Analytics Logs ingestion/retention), see `log-analytics.md`. For Application Insights, see `application-insights.md`.

> **Trap**: Platform metrics (CPU, memory, network, etc.) emitted by Azure resources are **free**; do not include them in cost estimates. Only custom metrics and Prometheus (Azure Monitor workspace) metrics are billable.

> **Trap (Data Restore minimum)**: Data Restore has a minimum of 2 TB and 12-hour duration; even restoring 1 GB incurs the 2 TB minimum charge.

> **Trap (mixed units)**: Azure Monitor meters use `10M`, `1 GB`, `1 GB/Month`, `1 GB/Day`, `1/Day`, `1/Month`, `1K`, and `1` units. The script's `MonthlyCost` is only correct for hourly and `1/Day` meters; verify units before reporting costs.

## Query Pattern

### Basic Logs ingestion

ServiceName: Azure Monitor
SkuName: Basic Logs
MeterName: Basic Logs Data Ingestion
Quantity: 50

### Prometheus / Azure Monitor workspace ingestion

ServiceName: Azure Monitor
SkuName: Metric Samples Ingested
MeterName: Metric Samples Ingested Metric samples

### Prometheus metrics queries

ServiceName: Azure Monitor
SkuName: Prometheus Metrics Queries
MeterName: Prometheus Metrics Queries Metric samples

### Commitment tier (100 GB example)

ServiceName: Azure Monitor
SkuName: 100 GB Commitment Tier
MeterName: 100 GB Commitment Tier Capacity Reservation

> **Note**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost.

## Meter Names

| Meter                                         | skuName                          | unitOfMeasure | Notes                                                 |
| --------------------------------------------- | -------------------------------- | ------------- | ----------------------------------------------------- |
| `Metrics ingestion Metric samples`            | `Metrics ingestion`              | `10M`         | Custom metrics (preview, not yet billed)              |
| `Metric Samples Ingested Metric samples`      | `Metric Samples Ingested`        | `10M`         | Prometheus / AMW ingestion                            |
| `Metric Samples Processed Metric samples`     | `Metric Samples Processed`       | `10M`         | Prometheus / AMW DCR processing                       |
| `Prometheus Metrics Queries Metric samples`   | `Prometheus Metrics Queries`     | `10M`         | PromQL query cost (sub-cent)                          |
| `Metrics Export Metric Samples Exported`      | `Metrics Export`                 | `1K`          | Metric data export via DCE (sub-cent)                 |
| `Native Metric Queries API Calls`             | `Native Metric Queries`          | `1K`          | Tiered: first 1M calls free                           |
| `Basic Logs Data Ingestion`                   | `Basic Logs`                     | `1 GB`        | ~78% cheaper than Analytics; 30-day fixed retention   |
| `Auxiliary Logs Data Ingestion`               | `Auxiliary Logs`                 | `1 GB`        | Cheapest tier; custom tables only                     |
| `Logs Emitted From Cloud Pipeline Data Emitted` | `Logs Emitted From Cloud Pipeline` | `1 GB`     | Cloud pipeline log emission                           |
| `Data Archive`                                | `Data Archive`                   | `1 GB/Month`  | Long-term archive (up to 12 years)                    |
| `Search Queries Scanned`                      | `Search Queries`                 | `1 GB`        | Query cost for Basic/Auxiliary tables                 |
| `Search Jobs Scanned`                         | `Search Jobs`                    | `1 GB`        | Archive search job cost                               |
| `Data Restore`                                | `Data Restore`                   | `1 GB/Day`    | Archive restore, minimum 2 TB × 12 hours              |
| `Log Analytics data export Data Exported`     | `Log Analytics data export`      | `1 GB`        | Continuous data export                                |
| `Platform Logs Data Processed`                | `Platform Logs`                  | `1 GB`        | Diagnostic settings → Storage/Event Hub               |
| `Logs Processed GB`                           | `Logs Processed`                 | `1`           | DCR transformation processing                         |
| `Data Replication Data Replicated`            | `Data Replication`               | `1 GB`        | Cross-workspace replication                           |
| `Standard Web Test Execution`                 | `Standard Web Test`              | `1`           | Availability test execution (sub-cent)                |
| `Alerts Metric Monitored`                     | `Alerts`                         | `1/Month`     | Tiered: first 10 signals free                         |
| `Alerts Resource Monitored at {N} Minute Frequency` | `Alerts`                   | `1/Month`     | Log search alerts: 1/5/10/15 min frequencies          |
| `Alerts System Log Monitored at {N} Minute Frequency` | `Alerts`                 | `1/Month`     | System log alerts: 10× Resource Monitored rate        |
| `{N} GB Commitment Tier Capacity Reservation` | `{N} GB Commitment Tier`         | `1/Day`       | Volume discounts (100–50000 GB/day)                   |

> **Note**: Notification meters (Emails, SMS, Voice Calls, Webhooks, Push, ITSM) also bill under Azure Monitor with tiered pricing and free grants. Query with `SkuName: Notifications`, `SkuName: Emails`, or `SkuName: SMS Country Code {N}`.

## Cost Formula

```
Prometheus     = (samples / 10M × ingestion_retailPrice) + (samples / 10M × processing_retailPrice)
Log Ingestion  = ingestedGB × retailPrice (per log tier: Basic, Auxiliary, Cloud Pipeline)
Archive        = archiveGB × retailPrice (per GB/month)
Search/Restore = scannedGB × retailPrice (per query/job)
Alerts         = alertRules × retailPrice (per rule/month; first 10 metric signals free)
Commitment     = retailPrice × 30 (unit is 1/Day)
```

## Notes

- **Platform metrics are free**; only custom metrics and Prometheus metrics are billable
- **Prometheus / AMW**: Ingestion + processing are separate meters; queries are sub-cent per 10M samples
- **Basic Logs**: Search-only (no alerts/dashboards); 30-day retention. **Auxiliary Logs**: cheapest tier; custom tables only via Logs Ingestion API
- **Sentinel-enabled workspaces**: Basic Logs ingestion uses Sentinel meters; Auxiliary Logs remain under Azure Monitor
- **Data Restore**: Minimum 2 TB × 12-hour duration; plan restores carefully
- Commitment tiers (100–50000 GB/day) provide volume discounts; overage billed at effective rate
- Alerts: metric alerts (first 10 signals free), log search alerts priced by evaluation frequency, dynamic thresholds priced per signal
- For Log Analytics workspace ingestion/retention, see `log-analytics.md`; for Application Insights, see `application-insights.md`
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
