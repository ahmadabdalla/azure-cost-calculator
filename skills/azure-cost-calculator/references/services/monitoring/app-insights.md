---
serviceName: Application Insights
category: monitoring
aliases:
  [
    App Insights,
    APM,
    Application Performance Monitoring,
    Application Performance,
    AppInsights,
    Azure Application Insights,
  ]
---

# Application Insights

**Primary cost**: Data ingestion per-GB + retention (via Log Analytics workspace)

> **Trap (workspace-based billing)**: **Workspace-based Application Insights has no separate cost** beyond Log Analytics ingestion and retention. Do NOT query a separate Application Insights meter — all telemetry costs are captured by the Log Analytics workspace. Only classic (non-workspace-based) Application Insights has separate billing, and it is being retired.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free per Log Analytics workspace. Always deduct this from the billable total: `billable_GB = total_GB - 5`.
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
Monthly Ingestion = retailPrice_per_GB × max(0, estimatedGB_per_month - 5)
Monthly Retention = retention_price_per_GB × retainedGB
Total = Monthly Ingestion + Monthly Retention
```

### Retention Calculation Detail

The first 31 days of retention are **free**. Charges apply for data retained beyond 31 days.

**How to calculate retained GB**: For steady-state ingestion of X GB/day, the volume of data in the chargeable retention window is:

```
Retained GB = dailyIngestionGB × chargeableDays
where chargeableDays = min(retentionPeriodDays - 31, actualDaysOfData - 31)
```

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
- All Application Insights data is stored in and priced via the connected Log Analytics workspace
- First 5 GB/month ingestion free per workspace (shared with all services using the workspace)
- First 31 days of retention included free
- Sampling can reduce telemetry volume and costs (e.g., 50% sampling = 50% less data ingested)
- Availability tests (multi-step web tests) may have additional costs for web test runs
- Maximum retention period: 730 days (2 years)
- For commitment tier pricing (100+ GB/day), see `log-analytics.md` commitment tiers section
