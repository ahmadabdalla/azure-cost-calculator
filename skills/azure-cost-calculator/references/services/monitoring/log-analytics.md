---
serviceName: Log Analytics
category: monitoring
aliases: [OMS, LA, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite]
primaryCost: "Data ingestion per-GB + retention beyond free period (90 days Sentinel / 31 days standard)"
hasFreeGrant: true
privateEndpoint: true
---

# Log Analytics

> **Trap**: The meter names `'Pay-as-you-go Data Ingested'` and `'Data Ingestion'` do NOT exist in `australiaeast`. The correct Log Analytics meter is `'Analytics Logs Data Analyzed'` with skuName `'Analytics Logs'`.
> **Trap (ingestion free tier)**: The first **5 GB/month** of ingestion is free — **PAYG only** (not commitment tiers), per **billing account** (not per workspace). Always deduct this from the billable total when on PAYG: `billable_GB = total_GB - 5`. **This free tier does NOT apply when Microsoft Sentinel is enabled with simplified pricing**: billing for Analytics Logs shifts to Sentinel meters in that case (Azure Monitor pricing page footnote 4; `cost-logs` doc), so no LA PAYG free allocation exists. It **does** apply to the LA portion under Sentinel classic pricing (pre-July 2023, separate meters), but not to the Sentinel analysis meter.
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

ServiceName: Azure Monitor <!-- cross-service -->
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

| Meter                           | skuName          | unitOfMeasure | Notes                                                              |
| ------------------------------- | ---------------- | ------------- | ------------------------------------------------------------------ |
| `Analytics Logs Data Analyzed`  | `Analytics Logs` | `1 GB`        | Pay-as-you-go data ingestion                                       |
| `Analytics Logs Data Retention` | `Analytics Logs` | `1 GB`        | Retention beyond free period (90 days Sentinel / 31 days standard) |

## Cost Formula

| Ingestion scenario                             | Formula                                                  |
| ---------------------------------------------- | -------------------------------------------------------- |
| PAYG — no Sentinel or Sentinel classic pricing | `retailPrice_per_GB × max(0, estimatedGB_per_month - 5)` |
| PAYG — Sentinel simplified pricing             | Billed via Sentinel meters — see `security/sentinel.md`  |

```
Monthly Retention = retention_price_per_GB × retainedGB
Total = Monthly Ingestion + Monthly Retention
```

### Retention Calculation Detail

Free retention: **90 days** (Sentinel-enabled workspace) or **31 days** (standard). Charges apply beyond the free period up to max 730 days.

> **Trap (retention volume)**: `dailyIngestionGB` = total physical ingestion from `_IsBillable=true` tables — NOT billable ingestion after grant deductions. Defender P2 free grants and the PAYG free tier reduce **ingestion** cost but data is still stored and incurs **retention** charges. Only `_IsBillable=false` tables (AzureActivity, Heartbeat, Usage, Operation) are excluded from both.

| Data category                                           | Ingestion billed? | Retention billed? |
| ------------------------------------------------------- | ----------------- | ----------------- |
| Regular data (`_IsBillable=true`)                       | Yes               | Yes               |
| Defender P2 / free-tier grant data (`_IsBillable=true`) | No (credit)       | Yes               |
| AzureActivity, Heartbeat, etc. (`_IsBillable=false`)    | No                | No                |

```
freeDays = 90 if Sentinel enabled, 31 otherwise
Retained GB = dailyIngestionGB × chargeableDays     # dailyIngestionGB = all _IsBillable=true data
where chargeableDays = max(0, min(retentionPeriodDays, actualDaysOfData) - freeDays)
```

**Example** — Sentinel workspace, 2-year retention, 14.5 GB/day total (`_IsBillable=true`), 2 GB/day Defender-granted: chargeableDays = 730 − 90 = 640 → retainedGB = **14.5** × 640 = 9,280 (use 14.5, not 12.5 — grants don't reduce retention volume).

## Commitment Tier Details

For 100+ GB/day, commitment tiers (100, 200, 300, 400, 500, 1000, 2000, 5000, 10000, 25000, 50000) save 15–36% vs pay-as-you-go (e.g., 100 GB/day ≈ 15%, 500 ≈ 25%, 50000 ≈ 36%). Overage above the tier is billed at the same discounted effective rate, not PAYG — so slightly over-committing is safe.

## Notes

- Non-billable tables (AzureActivity, Heartbeat, Usage, Operation) have zero ingestion and retention cost — deduct from volume estimates
- Maximum retention period: 730 days (2 years)
- Application Insights data flows into Log Analytics workspace when using workspace-based Application Insights
- Sentinel uses Log Analytics workspaces but all workspace data (including App Insights telemetry) is billed via Sentinel meters (`ServiceName: Sentinel`) — do NOT add LA or App Insights ingestion for a Sentinel-enabled workspace; only LA retention meters apply beyond the 90-day free period (see `security/sentinel.md`)
- Commitment tiers require 100+ GB/day ingestion and provide volume discounts
- For Defender for Cloud related free data grants, see `security/defender-for-cloud.md`
- Data export and archive features have separate pricing
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
- For Basic Logs, Auxiliary Logs, archive, search, restore, export, and commitment tier meters see `monitoring/monitor.md` (ServiceName: Azure Monitor)
