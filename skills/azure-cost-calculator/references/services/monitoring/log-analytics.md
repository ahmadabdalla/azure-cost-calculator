---
serviceName: Log Analytics
category: monitoring
aliases: [OMS, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite]
billingNeeds: [Azure Monitor]
primaryCost: "Data ingestion per-GB + retention beyond free period (90 days Sentinel / 31 days standard)"
hasFreeGrant: true
privateEndpoint: true
---

# Log Analytics

> **Trap**: The meter names `'Pay-as-you-go Data Ingested'` and `'Data Ingestion'` do NOT exist in `australiaeast`. The correct Log Analytics meter is `'Analytics Logs Data Analyzed'` with skuName `'Analytics Logs'`.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free (Log Analytics workspace). Always deduct this from the billable total: `billable_GB = total_GB - 5`.
> **Trap (retention calculation)**: The free retention period depends on whether Microsoft Sentinel is enabled: **90 days** for Sentinel-enabled workspaces, **31 days** otherwise. For extended retention, the chargeable window is `retentionDays - freeDays` (where freeDays = 90 if Sentinel is enabled, 31 if not). At steady-state ingestion of X GB/day, the retained data volume is `X × (retentionDays - freeDays)`. This is the most commonly miscalculated component — agents often use 31 days for Sentinel workspaces (significantly overstating cost) or 90 days for non-Sentinel workspaces (understating cost).

## Query Pattern

### Log Analytics — pay-as-you-go ingestion (per GB)

ServiceName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Analyzed

### Log Analytics — data retention (beyond free period: 90 days if Sentinel enabled, 31 days otherwise)

ServiceName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Retention

### Commitment tier (100+ GB/day) — uses ServiceName: Azure Monitor

ServiceName: Azure Monitor
SkuName: 100 GB Commitment Tier
MeterName: 100 GB Commitment Tier Capacity Reservation

> **Note**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script now auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost.

## Key Fields

| Parameter     | How to determine                                | Example values                                                  |
| ------------- | ----------------------------------------------- | --------------------------------------------------------------- |
| `serviceName` | Fixed value for Log Analytics workspace pricing | `Log Analytics`                                                 |
| `skuName`     | Fixed value for pay-as-you-go tier              | `Analytics Logs`                                                |
| `meterName`   | Either ingestion or retention meter             | `Analytics Logs Data Analyzed`, `Analytics Logs Data Retention` |

## Meter Names

| Meter                           | skuName          | unitOfMeasure | Notes                              |
| ------------------------------- | ---------------- | ------------- | ---------------------------------- |
| `Analytics Logs Data Analyzed`  | `Analytics Logs` | `1 GB`        | Pay-as-you-go data ingestion       |
| `Analytics Logs Data Retention` | `Analytics Logs` | `1 GB`        | Retention beyond free period (90 days Sentinel / 31 days standard) |

## Cost Formula

```
Monthly Ingestion = retailPrice_per_GB × max(0, estimatedGB_per_month - 5)
Monthly Retention = retention_price_per_GB × retainedGB
Total = Monthly Ingestion + Monthly Retention
```

### Retention Calculation Detail

Free retention: **90 days** (Sentinel-enabled workspace) or **31 days** (standard). Charges apply beyond the free period up to max 730 days.

```
freeDays = 90 if Sentinel enabled, 31 otherwise
Retained GB = dailyIngestionGB × chargeableDays
where chargeableDays = max(0, min(retentionPeriodDays, actualDaysOfData) - freeDays)
```

**Example 1** — 90-day retention, **Sentinel-enabled** workspace, 5 GB/day: chargeableDays = 90 − 90 = 0 → retention cost = 0.

**Example 2** — 90-day retention, **standard** workspace, 5 GB/day: chargeableDays = 90 − 31 = 59 → retainedGB = 295 → Monthly retention = retentionPrice × 295.

## Commitment Tier Details

For 100+ GB/day, commitment tiers (100, 200, 300, 400, 500, 1000, 2000, 5000) save 15–30% vs pay-as-you-go (e.g., 100 GB/day ≈ 15%, 200 ≈ 20%, 500 ≈ 25%). Overage above the tier is billed at the same discounted effective rate, not PAYG — so slightly over-committing is safe.

## Notes

- First 5 GB/month ingestion free per workspace
- Free retention: **90 days** if Microsoft Sentinel is enabled on the workspace, **31 days** otherwise; longer retention charged per-GB/month
- Maximum retention period: 730 days (2 years)
- Application Insights data flows into Log Analytics workspace when using workspace-based Application Insights
- Sentinel uses Log Analytics workspaces and meters for its data ingestion and retention
- Commitment tiers require 100+ GB/day ingestion and provide volume discounts
- Data export and archive features have separate pricing
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
