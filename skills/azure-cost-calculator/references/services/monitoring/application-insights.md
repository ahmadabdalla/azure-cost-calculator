---
serviceName: Application Insights
category: monitoring
aliases: [App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights]
billingNeeds: [Log Analytics]
apiServiceName: Log Analytics
primaryCost: "Data ingestion per-GB + retention (via Log Analytics workspace)"
hasFreeGrant: true
privateEndpoint: true
---

# Application Insights

> **Trap**: Workspace-based Application Insights has no separate ingestion cost — all telemetry is billed through the Log Analytics workspace. If Microsoft Sentinel is enabled on the workspace (simplified pricing), App Insights ingestion is **absorbed into Sentinel meters** — do NOT add a separate App Insights or Log Analytics ingestion charge; include App Insights GB in Sentinel's `total_IsBillable_GB` instead (see `security/sentinel.md`). Classic (non-workspace-based) is deprecated.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free per Log Analytics billing account (PAYG only). This credit does **not** apply when Sentinel simplified pricing is active on the workspace (default for workspaces created after July 2023), because ingestion shifts to Sentinel meters. Only deduct when Sentinel is NOT enabled or uses classic pricing: `billable_GB = total_GB - 5`.
> **Trap (retention calculation)**: The first **90 days** of retention are free for Application Insights data (App\* tables). For extended retention, the chargeable window is `max(0, retentionDays - 90)`. At steady-state ingestion of X GB/day, the retained data volume is `X × max(0, retentionDays - 90)`.

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
| `Analytics Logs Data Retention` | `Analytics Logs` | `1 GB`        | Application telemetry retention beyond 90 days |

## Cost Formula

```
Monthly Ingestion (no Sentinel or classic pricing) = retailPrice_per_GB × max(0, estimatedGB_per_month - 5)
Monthly Ingestion (Sentinel simplified pricing)    = absorbed into Sentinel — include App Insights GB in Sentinel's total_IsBillable_GB; see security/sentinel.md
Monthly Retention = retention_price_per_GB × retainedGB  (retention charges start after 90 free days)
Total = Monthly Ingestion + Monthly Retention
```

### Retention Calculation Detail

The first 90 days of retention are **free** for Application Insights data (App\* tables). Charges apply for data retained beyond 90 days.

**How to calculate retained GB**: For steady-state ingestion of X GB/day, the volume of data in the chargeable retention window is:

```
Retained GB = dailyIngestionGB × chargeableDays
where chargeableDays = max(0, retentionPeriodDays - 90)  (at steady-state)
```

> **Note**: For newly created workspaces that haven't accumulated a full retention period of data, use `max(0, min(retentionPeriodDays, actualDaysOfData) - 90)`. At steady state, `actualDaysOfData` always exceeds the retention period, so the formula simplifies to `max(0, retentionPeriodDays - 90)`.

For example, with 180-day retention and 5 GB/day steady ingestion:

```
Chargeable days = 180 - 90 = 90 days
Retained GB = 5 × 90 = 450 GB
Monthly retention cost = retentionPrice × 450
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
- First 90 days of retention included free for Application Insights data (App\* tables); other workspace tables get 31 days
- Sampling can reduce telemetry volume and costs (e.g., 50% sampling = 50% less data ingested)
- Availability tests (multi-step web tests) may have additional costs for web test runs
- Maximum retention period: 730 days (2 years)
- For commitment tier pricing (100+ GB/day), see `log-analytics.md` commitment tiers section
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
