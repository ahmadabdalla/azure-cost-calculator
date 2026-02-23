---
serviceName: Application Insights
category: monitoring
aliases: [App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights]
billingNeeds: [Log Analytics]
primaryCost: "Data ingestion per-GB + retention (via Log Analytics workspace)"
hasFreeGrant: true
privateEndpoint: true
---

# Application Insights

> **Trap**: Workspace-based Application Insights has no separate cost — all telemetry is billed through Log Analytics. Classic (non-workspace-based) is deprecated.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free per Log Analytics billing account (PAYG only). This credit does **not** apply when Sentinel simplified pricing is active on the workspace (default for workspaces created after July 2023), because ingestion shifts to Sentinel meters. Only deduct when Sentinel is NOT enabled or uses classic pricing: `billable_GB = total_GB - 5`.
> **Trap (retention calculation)**: The first **31 days** of retention are free. For extended retention, the chargeable window is `retentionDays - 31`. At steady-state ingestion of X GB/day, the retained data volume is `X × (retentionDays - 31)`.

## Query Pattern

### Application Insights data ingestion (via Log Analytics workspace)

ServiceName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Analyzed

### Application Insights data retention (via Log Analytics workspace)

ServiceName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Retention

## Key Fields

| Parameter     | How to determine                                   | Example values                                                  |
| ------------- | -------------------------------------------------- | --------------------------------------------------------------- |
| `serviceName` | Fixed value - uses Log Analytics workspace pricing | `Log Analytics`                                                 |
| `skuName`     | Fixed value for pay-as-you-go tier                 | `Analytics Logs`                                                |
| `meterName`   | Either ingestion or retention meter                | `Analytics Logs Data Analyzed`, `Analytics Logs Data Retention` |

## Meter Names

| Meter                           | skuName          | unitOfMeasure | Notes                                          |
| ------------------------------- | ---------------- | ------------- | ---------------------------------------------- |
| `Analytics Logs Data Analyzed`  | `Analytics Logs` | `1 GB`        | Application telemetry data ingestion           |
| `Analytics Logs Data Retention` | `Analytics Logs` | `1 GB`        | Application telemetry retention beyond 31 days |

## Cost Formula

```
Monthly Ingestion (no Sentinel or classic pricing) = retailPrice_per_GB × max(0, estimatedGB_per_month - 5)
Monthly Ingestion (Sentinel simplified pricing)    = billed via Sentinel meters — see security/sentinel.md
Monthly Retention = retention_price_per_GB × retainedGB
Total = Monthly Ingestion + Monthly Retention
```

### Retention Calculation Detail

The first 31 days of retention are **free**. Charges apply for data retained beyond 31 days.

**How to calculate retained GB**: For steady-state ingestion of X GB/day, the volume of data in the chargeable retention window is:

```
Retained GB = dailyIngestionGB × chargeableDays
where chargeableDays = retentionPeriodDays - 31  (at steady-state)
```

> **Note**: For newly created workspaces that haven't accumulated a full retention period of data, use `min(retentionPeriodDays - 31, actualDaysOfData - 31)`. At steady state, `actualDaysOfData` always exceeds the retention period, so the formula simplifies to `retentionPeriodDays - 31`.

For example, with 90-day retention and 5 GB/day steady ingestion:

```
Chargeable days = 90 - 31 = 59 days
Retained GB = 5 × 59 = 295 GB
Monthly retention cost = retentionPrice × 295
```

## Telemetry Volume Estimation

Typical Application Insights telemetry volume per application instance:

- **Minimal monitoring** (basic requests/dependencies): 0.1-0.5 GB/month per instance
- **Standard monitoring** (requests, dependencies, exceptions, custom events): 0.5-2 GB/month per instance
- **Verbose monitoring** (detailed traces, performance counters, custom metrics): 2-10 GB/month per instance
- **High-frequency metrics** (1-second granularity custom metrics): 10+ GB/month per instance

> **Note**: Actual volume varies significantly based on traffic volume, sampling configuration, and telemetry types enabled.

## Notes

- Application Insights requires a Log Analytics workspace (workspace-based model)
- Classic Application Insights (non-workspace-based) is deprecated and scheduled for retirement
- First 5 GB/month ingestion free per billing account (PAYG only, shared with all services using the workspace); does not apply under Sentinel simplified pricing
- First 31 days of retention included free
- Sampling can reduce telemetry volume and costs (e.g., 50% sampling = 50% less data ingested)
- Availability tests (multi-step web tests) may have additional costs for web test runs
- Maximum retention period: 730 days (2 years)
- For commitment tier pricing (100+ GB/day), see `log-analytics.md` commitment tiers section
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
