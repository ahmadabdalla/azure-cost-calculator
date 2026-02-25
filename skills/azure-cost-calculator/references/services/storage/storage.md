---
serviceName: Storage
category: storage
aliases: [Blob Storage, Azure Files, Table Storage, Queue Storage, Azure Storage]
billingConsiderations: [Reserved Instances]
primaryCost: "Data stored per-GB/month (tiered) + operations per-10K + data retrieval per-GB"
privateEndpoint: true
---

# Storage Accounts (Blob)

> **Trap**: `productName = 'Blob Storage'` only covers **LRS/GRS/RA-GRS**. For ZRS/GZRS/RA-GZRS use `productName = 'General Block Blob v2'` — wrong productName returns zero results.

> **Trap (RA-GZRS)**: Hot/Cool RA-GZRS has **no Write Operations meter** — query with GZRS skuName instead (e.g., `Hot GZRS` + `Hot GZRS Write Operations`). RA-GRS similarly uses GRS write meter names. Data stored meters exist for all RA- variants at higher prices (~25% over non-RA).

> **Trap (Default Redundancy)**: Default to **Hot LRS** unless user explicitly requests otherwise. Always include `skuName` in filters — GRS is ~2× LRS, RA-GZRS ~3×. Wrong redundancy row inflates cost 200–300%.

> **Trap (Tiered Calculation)**: Do NOT multiply the tier-1 rate by the full volume. Hot tier returns 3 rows with `tierMinimumUnits` 0, 51200, 512000 — each rate applies only to GB within that band. Cool, Cold, and Archive use flat rates.

## Query Pattern

Template: `ServiceName: Storage`, `SkuName: {Tier} {Redundancy}`, `ProductName: {see Product Names}`, `MeterName: {see Meter Names}`

### LRS/GRS storage (productName: Blob Storage)

ServiceName: Storage
SkuName: Hot LRS
ProductName: Blob Storage
MeterName: Hot LRS Data Stored

### ZRS/GZRS storage (productName: General Block Blob v2)

ServiceName: Storage
SkuName: Hot ZRS
ProductName: General Block Blob v2
MeterName: Hot ZRS Data Stored

### Write operations (per-10K, use Quantity for scaling)

ServiceName: Storage
SkuName: Hot LRS
ProductName: Blob Storage
MeterName: Hot LRS Write Operations
Quantity: 50

## Key Fields

| Parameter     | How to determine         | Example values                               |
| ------------- | ------------------------ | -------------------------------------------- |
| `serviceName` | Always `Storage`         | `Storage`                                    |
| `skuName`     | Access tier + redundancy | `Hot LRS`, `Cool ZRS`, `Hot RA-GZRS`        |
| `productName` | See Product Names table  | `Blob Storage`, `General Block Blob v2`      |
| `meterName`   | See Meter Names table    | `Hot LRS Data Stored`, `Hot Read Operations` |

## Meter Names

| Meter                       | skuName       | productName             | unitOfMeasure | Notes                            |
| --------------------------- | ------------- | ----------------------- | ------------- | -------------------------------- |
| `Hot LRS Data Stored`       | `Hot LRS`     | `Blob Storage`          | `1 GB/Month`  | Tiered                           |
| `Hot ZRS Data Stored`       | `Hot ZRS`     | `General Block Blob v2` | `1 GB/Month`  | Tiered                           |
| `Hot GRS Data Stored`       | `Hot GRS`     | `Blob Storage`          | `1 GB/Month`  | Tiered                           |
| `Hot GZRS Data Stored`      | `Hot GZRS`    | `General Block Blob v2` | `1 GB/Month`  | Tiered                           |
| `Hot RA-GZRS Data Stored`   | `Hot RA-GZRS` | `General Block Blob v2` | `1 GB/Month`  | ~25% more than GZRS              |
| `Hot Read Operations`       | _(any Hot)_   | _(varies)_              | `10K`         | Generic, not redundancy-specific |
| `Hot LRS Write Operations`  | `Hot LRS`     | `Blob Storage`          | `10K`         | Redundancy-specific              |
| `Hot GZRS Write Operations` | `Hot GZRS`    | `General Block Blob v2` | `10K`         | Shared by GZRS & RA-GZRS        |
| `Cool Data Retrieval`       | _(any Cool)_  | _(varies)_              | `1 GB`        | Also: Cold/Archive Data Retrieval |

Meter pattern: `{Tier} {Redundancy} Data Stored`, `{Tier} Read Operations` or `{Tier} ZRS Read Operations`, `{Tier} {Redundancy} Write Operations` (RA-* reuses non-RA write meter name, e.g., RA-GZRS → `Hot GZRS Write Operations`, RA-GRS → `Hot GRS Write Operations`)

## Cost Formula

```
Hot tier: tiered — rows with tierMinimumUnits 0, 51200, 512000 GB.
Each rate applies ONLY to GB within that band. Cool/Cold/Archive: flat rate.

Example: 60 TB (61,440 GB) Hot LRS →
  Tier 1: 51,200 GB × tier1_retailPrice
  Tier 2: 10,240 GB × tier2_retailPrice  (61,440 − 51,200)

Monthly = Σ(retailPrice × GB_in_tier) + (readOps/10K × readPrice)
       + (writeOps/10K × writePrice) + (retrievedGB × retrieval_retailPrice)
```

## Notes

- Read operations: LRS/GRS/RA-GRS use generic name (`Hot Read Operations`); ZRS/GZRS/RA-GZRS use `{Tier} ZRS Read Operations`. Cold tier uses per-redundancy names.
- Write operations: RA-* variants reuse non-RA meters (RA-GZRS → `Hot GZRS Write Operations`, RA-GRS → `Hot GRS Write Operations`)
- Early delete: Cool 30d, Cold 90d, Archive 180d — rate equals data stored rate, prorated
- Archive tier: LRS/GRS/RA-GRS only (no ZRS/GZRS/RA-GZRS); Cold tier has no Reserved Instances
- PE sub-resources (never-assume): `blob`, `file`, `queue`, `table`, `dfs`, `web`. Secondary variants (`blob_secondary`, etc.) for RA-GRS/RA-GZRS.
- Azure Files, Table, and Queue use distinct `productName` values under `serviceName: Storage` — query each sub-product separately

## Product Names

| Redundancy         | productName             |
| ------------------ | ----------------------- |
| LRS, GRS, RA-GRS   | `Blob Storage`          |
| ZRS, GZRS, RA-GZRS | `General Block Blob v2` |
| Premium LRS/ZRS    | `Premium Block Blob`    |
