---
serviceName: App Configuration
category: developer-tools
aliases: [Feature Flags, Configuration Store]
primaryCost: "Per-tier daily rate × 30 + per-request overage beyond included daily quota"
hasKnownRates: true
hasFreeGrant: true
privateEndpoint: true
---

# App Configuration

> **Trap (unfiltered query)**: Querying with only `ServiceName` returns meters from all four tiers (Free, Developer, Standard, Premium) plus overage and snapshot meters. Always filter by `SkuName` and `MeterName` to isolate the target tier.

> **Trap (Developer overage unit)**: Developer overage uses `1K` unitOfMeasure while Standard and Premium use `10K`. Do not mix units when comparing cross-tier overage costs — Developer effective rate per request is higher.

## Query Pattern

### Standard tier instance — most common production config

ServiceName: App Configuration
SkuName: Standard
MeterName: Standard Instance
InstanceCount: 2

### Premium tier instance (includes 1 replica)

ServiceName: App Configuration
SkuName: Premium
MeterName: Premium Instance

### Standard request overage

ServiceName: App Configuration
SkuName: Standard
MeterName: Standard Overage Operations

## Key Fields

| Parameter | How to determine | Example values |
| --- | --- | --- |
| `serviceName` | Always `App Configuration` | `App Configuration` |
| `productName` | Always `App Configuration` | `App Configuration` |
| `skuName` | Tier selection (never-assume) | `Free`, `Developer`, `Standard`, `Premium` |
| `meterName` | Billing component | `Standard Instance`, `Standard Overage Operations` |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| --- | --- | --- | --- |
| `{Tier} Instance` | per tier | `1/Day` | Daily store fee; Free is zero |
| `{Tier} Overage Operations` | Dev/Std/Prem | `1K` or `10K` | Developer: `1K`; Standard/Premium: `10K` |
| `{Tier} Replica Instance` | Std/Prem | `1/Day` | Per additional replica |
| `{Tier} Replica Overage Operations` | Std/Prem | `10K` | Per-replica request overage |
| `{Tier} Snapshots Overage` | Dev/Std/Prem | `1 MB/Day` | Sub-cent; see Known Rates |
| `{Tier} Experimentation Events` | all tiers | `1K` | Currently zero-priced |

> `{Tier}` expands to `Free`, `Developer`, `Standard`, or `Premium` — use exact tier prefix in queries (e.g., `Standard Instance`, `Premium Replica Instance`).

## Cost Formula

```
Monthly = instance_retailPrice × 30 × instanceCount
        + replica_retailPrice × 30 × replicaCount
        + max(0, dailyRequests − includedRequests) / unitSize × overage_retailPrice × 30
        + max(0, replicaDailyReqs − includedReplicaReqs) / unitSize × replica_overage_retailPrice × 30
        + max(0, snapshotMB − includedMB) × snapshot_retailPrice × 30
```

## Notes

- **Free tier**: 1,000 requests/day (hard cap — HTTP 429), 10 MB storage, 10 MB snapshots; no overage billing, no replicas, no PE support
- **Included daily requests**: Developer 3K; Standard 200K per store + 200K per replica; Premium 800K per store + 800K per replica (1 replica included)
- **Premium includes 1 replica** in the base daily charge — `Premium Replica Instance` is for additional replicas only
- **Daily billing**: All instance meters use `1/Day`. The script auto-multiplies by 30, so `MonthlyCost` is already the **monthly** cost. Do NOT pass `Quantity: 30` or multiply again; do NOT use 730 hours
- **Private Endpoints**: Supported on Developer (1), Standard (10), Premium (40) — not available on the Free tier; see `networking/private-link.md` for PE and DNS zone pricing

## Known Rates

| Meter | Unit | Published Rate (USD) | Free Grant |
| --- | --- | --- | --- |
| `{Tier} Snapshots Overage` | 1 MB/Day | $0.0016 | Dev: 500 MB, Std: 1 GB, Prem: 4 GB |
| `Developer Overage Operations` | 1K | $0.04 | 3,000 requests/day |
| `Standard/Premium Overage Operations` | 10K | $0.06 | Std: 200K/day, Prem: 800K/day |

> These rates match `retailPrice` values from the API. For non-USD currencies, use the currency derivation method in [regions-and-currencies.md](../../regions-and-currencies.md).
