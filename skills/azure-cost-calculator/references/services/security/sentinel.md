---
serviceName: Sentinel
category: security
aliases: [SIEM, SOAR, Azure Sentinel]
billingNeeds: [Log Analytics]
primaryCost: "Per-GB ingestion (PAYG or commitment tier per day × 30) + optional Basic Logs, data lake storage, add-on fees."
---

# Microsoft Sentinel

> **Trap (MANDATORY — DO NOT substitute commitment tiers)**: ALWAYS use `SkuName: Pay-as-you-go` unless the user **explicitly names** a commitment tier (e.g., "use the 400 GB commitment tier"). A daily ingestion volume like "400 GB/day" is NOT a request for the 400 GB Commitment Tier — it is a volume figure; multiply by 30 and price at PAYG. Even when the daily volume exactly matches a tier name, use PAYG. If a commitment tier would save money, note the saving in Assumptions but calculate with PAYG. Ignoring this rule causes significant cost variance.
>
> **Agent instruction**: Before submitting any Sentinel estimate, verify that `SkuName` is `Pay-as-you-go` unless the user's exact words requested a commitment tier by name. If you selected a commitment tier, STOP and recalculate with PAYG.

> **Trap (inflated total)**: Unfiltered `ServiceName: Sentinel` sums all 23 SKUs including every commitment tier — `totalMonthlyCost` is wildly inflated. Always filter by the specific `SkuName` the customer uses — PAYG or one commitment tier, not both.

> **Trap (DO NOT double-count workspace ingestion)**: Sentinel PAYG and Commitment Tier prices **already include** all workspace ingestion (including Application Insights telemetry, custom logs, and any other `_IsBillable=true` data) — DO NOT add a separate Log Analytics or App Insights ingestion charge. Only add Log Analytics costs for: (1) retention beyond the included free period (90 days for Sentinel-enabled workspaces), (2) data ingested into workspaces that do not have Sentinel enabled, or (3) non-Sentinel workspace features billed separately. If you add LA or App Insights ingestion on top of Sentinel ingestion, the estimate will be ~2× the real cost.

## Query Pattern

### PAYG ingestion — 200 GB/day (6,000 GB/month)

ServiceName: Sentinel
SkuName: Pay-as-you-go
Quantity: 6000

### Commitment tier — 200 GB/day

ServiceName: Sentinel
SkuName: 200 GB Commitment Tier

### Basic Logs analysis — 300 GB/month

ServiceName: Sentinel
SkuName: Basic Logs
Quantity: 300

### Data lake storage — 500 GB retained

ServiceName: Sentinel
SkuName: Data lake storage
Quantity: 500

## Key Fields

| Parameter     | How to determine          | Example values                                                          |
| ------------- | ------------------------- | ----------------------------------------------------------------------- |
| `serviceName` | Always `Sentinel`         | `Sentinel`                                                              |
| `productName` | Always `Sentinel`         | `Sentinel`                                                              |
| `skuName`     | Ingestion model or add-on | `Pay-as-you-go`, `200 GB Commitment Tier`, `Basic Logs`                 |
| `meterName`   | Matches SKU with suffix   | `Pay-as-you-go Analysis`, `200 GB Commitment Tier Capacity Reservation` |

## Meter Names

| Meter                                         | skuName                        | unitOfMeasure | Notes                               |
| --------------------------------------------- | ------------------------------ | ------------- | ----------------------------------- |
| `Pay-as-you-go Analysis`                      | `Pay-as-you-go`                | `1 GB`        | Primary PAYG ingestion + analysis   |
| `{N} GB Commitment Tier Capacity Reservation` | `{N} GB Commitment Tier`       | `1/Day`       | Daily flat rate; tiers: 50–50000 GB |
| `Basic Logs Analysis`                         | `Basic Logs`                   | `1 GB`        | Reduced-cost log analysis           |
| `Data lake storage Data Stored`               | `Data lake storage`            | `1 GB/Month`  | Long-term storage                   |
| `Data lake ingestion Data Processed`          | `Data lake ingestion`          | `1 GB`        | Ingestion into data lake            |
| `Free Benefit - M365 Defender Analysis`       | `Free Benefit - M365 Defender` | `1 GB`        | Zero cost — free M365 data          |

> Other SKUs (query individually): `Data lake query` (1 GB, sub-cent), `Advanced Data Insights` (1 Hour), `Data processing` (1 GB), `Solution for SAP Applications` (1/Hour), `Classic Auxiliary Logs Analysis` (1 GB), `Free Trial` (1 GB).

## Cost Formula

### Billable GB (simplified pricing)

```
defender_free_GB = min(security_table_GB, serverCount × 0.5 × 30)   # Defender P2 (see defender-for-cloud.md)
m365_free_GB    = min(m365_table_GB, userCount × 0.005 × 30)        # M365 E5; tables don't overlap with P2
billableGB      = total_IsBillable_GB - defender_free_GB - m365_free_GB
```

> Grants are volume deductions (applied before tier pricing), for ingestion only — retention uses total physical ingestion (see `log-analytics.md`). P2 grant requires Defender auto-provisioned DCRs. No LA 5 GB/month free tier under simplified pricing.

```
PAYG:       Monthly = payg_retailPrice × billableGB
Commitment: Monthly = tier_retailPrice × 30 + (tier_retailPrice ÷ tierGB) × max(0, billableGB ÷ 30 - tierGB) × 30
Basic Logs: Monthly = basic_retailPrice × queryGB
Data Lake:  Monthly = storage_retailPrice × storedGB + ingestion_retailPrice × ingestedGB + query_retailPrice × queriedGB
```

> **Example — shared workspace with App Insights (simplified PAYG, no Defender):** `total_IsBillable_GB` = security logs (35 GB) + App Insights telemetry (25 GB) = 60 GB; `billableGB` = 60 − 0 = 60 → Sentinel cost = 60 × payg_retailPrice; App Insights ingestion = absorbed into Sentinel total; LA ingestion = covered. No LA 5 GB free grant under simplified pricing.

## Notes

- Commitment tiers use `1/Day` billing — script auto-multiplies by 30; overage beyond the tier is billed at the **effective per-GB commitment tier rate** (tier_retailPrice ÷ tierGB), not PAYG — no separate overage meter exists in the API
- Commitment tiers: 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000, 25000, 50000 GB/day
- Basic Logs: supports simple log alerts only (no full analytics/scheduled rules), 30-day retention, for medium-touch troubleshooting data; when Sentinel is enabled, Basic Logs use **Sentinel meters** (`Basic Logs Analysis`) — do not also bill Azure Monitor `Basic Logs Data Ingestion`
- Regional price variance is significant: commitment tiers cost ~25% more in uksouth vs eastus
- Sentinel PAYG and Commitment Tier rates are **unified** — they replace (not add to) standalone Azure Monitor/Log Analytics ingestion charges; do not sum both
- Post-July 2023 workspaces use **simplified pricing** (single unified meter); legacy workspaces use **classic** meters with `Classic` prefix (e.g., `Classic Pay-as-you-go Analysis`) — do not mix
- For standalone Log Analytics meters (`Analytics Logs Data Analyzed`, retention) see `monitoring/log-analytics.md`; for Basic Logs, archive, and export meters see `monitoring/monitor.md`
- No native free tier — Sentinel has a 31-day free **trial** (10 GB/day) and cross-product grants: Defender for Servers P2 (500 MB/node/day, see `defender-for-cloud.md`), M365 E5 (5 MB/user/day); these require separate licenses and are not Sentinel-included units
