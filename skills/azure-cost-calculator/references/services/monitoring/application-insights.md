---
serviceName: Application Insights
category: monitoring
aliases: [App Insights, APM, Application Performance Monitoring, Application Performance, AppInsights, Azure Application Insights]
billingNeeds: [Log Analytics, Azure Monitor]
apiServiceName: Log Analytics
queryServiceNames: [Azure Monitor]
primaryCost: "Data ingestion, retention, and optional web test executions"
hasFreeGrant: true
privateEndpoint: true
---

# Application Insights

> **Trap**: Workspace-based Application Insights has no separate ingestion cost; all telemetry is billed through the Log Analytics workspace. If Microsoft Sentinel is enabled on the workspace (simplified pricing), App Insights ingestion is **absorbed into Sentinel meters**; do NOT add a separate App Insights or Log Analytics ingestion charge; include App Insights GB in Sentinel's `total_IsBillable_GB` instead (see `security/sentinel.md`). Classic (non-workspace-based) is deprecated.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free per Log Analytics billing account (PAYG only). This credit does **not** apply when Sentinel simplified pricing is active on the workspace (default for workspaces created after July 2023), because ingestion shifts to Sentinel meters. Only deduct when Sentinel is NOT enabled or uses classic pricing: `billable_GB = total_GB - 5`.
> **Trap (retention calculation)**: The first **90 days** of retention are free for Application Insights data (App\* tables). For extended retention, the chargeable window is `max(0, retentionDays - 90)`. At steady-state ingestion of X GB/day, the retained data volume is `X × max(0, retentionDays - 90)`.
> **Trap (web test sub-cent)**: Standard Web Test Execution uses sub-cent regional rates; use `UnitPrice`/`retailPrice` from the API and multiply by execution count. Do not treat a zero-formatted `MonthlyCost` as free.

## Query Pattern

### Application Insights data ingestion (via Log Analytics workspace, tiered PAYG meter)

ServiceName: Log Analytics
ProductName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Ingestion
Quantity: 50 # estimated GB/month

### Application Insights data retention (via Log Analytics workspace)

ServiceName: Log Analytics
ProductName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Retention

### Application Insights availability tests (Standard Web Test)

ServiceName: Azure Monitor
ProductName: Azure Monitor
SkuName: Standard Web Test
MeterName: Standard Web Test Execution
Quantity: 43800 # 1 test every 5 minutes from 5 locations for 730 hours

## Key Fields

| Parameter     | How to determine                                    | Example values                                                                                  |
| ------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `serviceName` | Billing surface for telemetry or availability tests | `Log Analytics`, `Azure Monitor`                                                                |
| `productName` | Match the service billing surface                   | `Log Analytics`, `Azure Monitor`                                                                |
| `skuName`     | PAYG logs or Standard Web Test                      | `Analytics Logs`, `Standard Web Test`                                                           |
| `meterName`   | Ingestion, retention, or web test execution meter   | `Analytics Logs Data Ingestion`, `Analytics Logs Data Retention`, `Standard Web Test Execution` |

## Meter Names

| Meter                           | productName     | skuName             | unitOfMeasure | Notes                                          |
| ------------------------------- | --------------- | ------------------- | ------------- | ---------------------------------------------- |
| `Analytics Logs Data Ingestion` | `Log Analytics` | `Analytics Logs`    | `1 GB`        | Application telemetry data ingestion (tiered)  |
| `Analytics Logs Data Retention` | `Log Analytics` | `Analytics Logs`    | `1 GB/Month`  | Application telemetry retention beyond 90 days |
| `Standard Web Test Execution`   | `Azure Monitor` | `Standard Web Test` | `1`           | Availability test execution (sub-cent)         |

## Cost Formula

```
Monthly Ingestion (no Sentinel or classic pricing) = applicable_tier_price_per_GB × max(0, estimatedGB_per_month - 5)
Monthly Ingestion (Sentinel simplified pricing)    = absorbed into Sentinel; include App Insights GB in Sentinel's total_IsBillable_GB; see security/sentinel.md
Monthly Retention = retention_price_per_GB × retainedGB  (retention charges start after 90 free days)
Monthly Web Tests = webtest_unitPrice × executionsPerMonth
  where executionsPerMonth = tests × locations × (730 × 60 / frequencyMinutes)
Total = Monthly Ingestion + Monthly Retention + Monthly Web Tests
```

### Retention Calculation Detail

The first 90 days of retention are **free** for Application Insights data (App\* tables). Charges apply for data retained beyond 90 days.

**How to calculate retained GB**: For steady-state ingestion of X GB/day, the volume of data in the chargeable retention window is:

```
Retained GB = dailyIngestionGB × chargeableDays
where dailyIngestionGB = monthlyIngestionGB / 30  (house convention: 30-day month)
      chargeableDays   = max(0, retentionPeriodDays - 90)  (at steady-state)
```

> **Note**: For newly created workspaces that haven't accumulated a full retention period of data, use `max(0, min(retentionPeriodDays, actualDaysOfData) - 90)`. At steady state, `actualDaysOfData` always exceeds the retention period, so the formula simplifies to `max(0, retentionPeriodDays - 90)`.

For example, with 180-day retention and 5 GB/day steady ingestion:

```
Chargeable days = 180 - 90 = 90 days
Retained GB = 5 × 90 = 450 GB
Monthly retention cost = retentionPrice × 450
```

## Notes

- Application Insights requires a Log Analytics workspace (workspace-based model)
- Classic Application Insights (non-workspace-based) is deprecated and scheduled for retirement
- `Analytics Logs Data Ingestion` is tiered: 0-price at tier 0, paid ingestion starts at tier 5 GB; do not trust the script `summary.totalMonthlyCost` for this meter; apply the 5 GB PAYG grant manually
- First 5 GB/month ingestion free per billing account (PAYG only, shared with all services using the workspace); does not apply under Sentinel simplified pricing
- First 90 days of retention included free for Application Insights data (App\* tables); other workspace tables get 31 days
- Sampling can reduce telemetry volume and costs (e.g., 50% sampling = 50% less data ingested)
- Typical telemetry volume per instance: 0.1–0.5 GB/month (minimal), 0.5–2 GB/month (standard), 2–10 GB/month (verbose); varies by traffic and sampling config
- Availability tests: Standard web tests use `ServiceName: Azure Monitor`, `ProductName: Azure Monitor`, `SkuName: Standard Web Test`, `MeterName: Standard Web Test Execution`; multi-step web tests are legacy and use `ServiceName: Application Insights`, `SkuName: Basic`, `MeterName: Multi-step Web Test`
- Maximum retention period: 730 days (2 years)
- For commitment tier pricing (100+ GB/day), see `log-analytics.md` commitment tiers section
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
