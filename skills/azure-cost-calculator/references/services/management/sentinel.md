---
serviceName: Sentinel
category: management
aliases: [SIEM, SOAR]
---

# Microsoft Sentinel

**Primary cost**: Per-GB ingestion (PAYG or commitment tier per day × 30) + optional Basic Logs, data lake storage, and add-on analysis fees.

> **Trap (inflated total)**: Unfiltered `ServiceName: Sentinel` sums all 23 SKUs including every commitment tier — `totalMonthlyCost` is wildly inflated. Always filter by the specific `SkuName` the customer uses — PAYG or one commitment tier, not both.

> **Trap (Sentinel vs Log Analytics)**: Sentinel meters cover analysis/SIEM only. The underlying Log Analytics workspace ingestion, retention, and storage are billed separately under `ServiceName: Log Analytics`. Always price both services.

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
| `Free Benefit - M365 Defender Analysis`       | `Free Benefit - M365 Defender` | `1 GB`        | $0 — free M365 data                 |

> Other SKUs (query individually): `Data lake query` (1 GB, sub-cent), `Advanced Data Insights` (1 Hour), `Data processing` (1 GB), `Solution for SAP Applications` (1/Hour), `Classic Auxiliary Logs Analysis` (1 GB), `Free Trial` (1 GB).

## Cost Formula

```
PAYG:       Monthly = payg_retailPrice × totalGB
Commitment: Monthly = tier_retailPrice × 30 + payg_retailPrice × max(0, dailyGB - tierGB) × 30
Basic Logs: Monthly = basic_retailPrice × queryGB
Data Lake:  Monthly = storage_retailPrice × storedGB + ingestion_retailPrice × ingestedGB + query_retailPrice × queriedGB
```

## Notes

- Reserved pricing is **not available** — RI queries return zero results
- Commitment tiers use `1/Day` billing — script auto-multiplies by 30; overage billed at PAYG rate — query `Pay-as-you-go` SKU
- Commitment tiers: 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000, 25000, 50000 GB/day
- Basic Logs: search-only (no alerts/detections), 30-day retention, for high-volume low-value logs
- Regional price variance is significant: commitment tiers cost ~25% more in uksouth vs eastus
