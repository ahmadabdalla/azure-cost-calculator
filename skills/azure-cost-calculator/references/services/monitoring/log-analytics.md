---
serviceName: Log Analytics
category: monitoring
aliases: [OMS, LA, Workspace, Logs, Log Analytics Workspace, Azure Monitor Logs, Operations Management Suite]
primaryCost: "Data ingestion per-GB + retention beyond free period (90 days Sentinel / 31 days standard)"
hasFreeGrant: true
privateEndpoint: true
---

# Log Analytics

> **Trap (tiered meter)**: The correct ingestion meter `'Analytics Logs Data Ingestion'` returns **two rows per region** (tiered pricing): tier 1 at `tierMinimumUnits=0` is free (first 5 GB), tier 2 at `tierMinimumUnits=5` is the charged rate. Use the tier-2 `retailPrice` for per-GB cost. The legacy meter `'Analytics Logs Data Analyzed'` returns a mostly uniform legacy rate and does not reliably reflect current regional tiered ingestion pricing — do NOT use it.
> **Trap (ingestion free tier)**: The first **5 GB/month** is free, **PAYG only** (not commitment tiers), per **billing account** (not per workspace). Deduct from billable total: `billable_GB = max(0, total_GB - 5)`. This free tier does NOT apply when Sentinel simplified pricing is enabled (ingestion shifts to Sentinel meters; see `security/sentinel.md`).
> **Trap (retention calculation)**: Free retention: **90 days** (Sentinel-enabled) or **31 days** (standard). Chargeable window = `retentionDays - freeDays`. Retention volume uses ALL `_IsBillable=true` data (Defender P2 grants reduce ingestion cost but NOT retention volume).

## Query Pattern

### Log Analytics: pay-as-you-go ingestion (per GB, 50 GB/month example)

ServiceName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Ingestion
Quantity: 50

> Use the tier-2 row (`tierMinimumUnits=5.0`) retailPrice. Deduct 5 GB free grant from quantity.

### Log Analytics: data retention (beyond free period)

ServiceName: Log Analytics
SkuName: Analytics Logs
MeterName: Analytics Logs Data Retention

### Commitment tier (100+ GB/day): uses ServiceName: Azure Monitor

> Commitment tiers are billed under Azure Monitor, not Log Analytics.

ServiceName: Azure Monitor <!-- cross-service -->
SkuName: 100 GB Commitment Tier
MeterName: 100 GB Commitment Tier Capacity Reservation

> **Note**: Commitment tier meters have `unitOfMeasure = '1/Day'`. The script auto-multiplies by 30, so `MonthlyCost` is the monthly cost.

## Key Fields

| Parameter     | How to determine                                | Example values                                                    |
| ------------- | ----------------------------------------------- | ----------------------------------------------------------------- |
| `serviceName` | Fixed value for Log Analytics workspace pricing | `Log Analytics`                                                   |
| `skuName`     | Fixed for PAYG; tier-specific for commitments   | `Analytics Logs`, `100 GB Commitment Tier`                        |
| `meterName`   | Ingestion, retention, or commitment tier meter  | `Analytics Logs Data Ingestion`, `Analytics Logs Data Retention`  |

## Meter Names

| Meter                           | skuName          | unitOfMeasure | Notes                                                              |
| ------------------------------- | ---------------- | ------------- | ------------------------------------------------------------------ |
| `Analytics Logs Data Ingestion` | `Analytics Logs` | `1 GB`        | PAYG ingestion (tiered: 0–5 GB free, >5 GB charged)               |
| `Analytics Logs Data Retention` | `Analytics Logs` | `1 GB/Month`  | Retention beyond free period (90 days Sentinel / 31 days standard) |

## Cost Formula

```
Ingestion (PAYG)  = tier2_retailPrice × max(0, estimatedGB_per_month - 5)
Retention         = retention_retailPrice × dailyIngestionGB × max(0, retentionDays - freeDays)
  where freeDays = 90 (Sentinel enabled) or 31 (standard)
  dailyIngestionGB = all _IsBillable=true data (grants don't reduce retention volume)
Commitment Tier   = commitment_retailPrice × 30   # unitOfMeasure = 1/Day
Total = Ingestion + Retention (+ Commitment Tier if applicable, replaces Ingestion)
```

> Sentinel simplified pricing: ingestion billed via Sentinel meters; only LA retention applies beyond 90-day free period (see `security/sentinel.md`).

## Notes

- Non-billable tables (AzureActivity, Heartbeat, Usage, Operation) have zero ingestion and retention cost; deduct from volume estimates
- Interactive retention maximum: 730 days (2 years); long-term retention (archive): up to 12 years via `Data Archive` meter under Azure Monitor
- Application Insights data flows into Log Analytics workspace when using workspace-based Application Insights
- Sentinel simplified pricing workspaces: all ingestion billed via Sentinel meters; do NOT add LA ingestion; only LA retention meters apply beyond 90 days (see `security/sentinel.md`)
- Commitment tiers (100–50000 GB/day) save ~15–36% vs PAYG; overage billed at discounted effective rate
- For Defender for Cloud free data grants, see `security/defender-for-cloud.md`
- Private endpoints require AMPLS (Azure Monitor Private Link Scope)
- For Basic Logs, Auxiliary Logs, archive, search, restore, export, and commitment tier meters see `monitoring/monitor.md` (ServiceName: Azure Monitor)
