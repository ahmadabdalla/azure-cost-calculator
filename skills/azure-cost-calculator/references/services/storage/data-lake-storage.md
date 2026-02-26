---
serviceName: Storage
category: storage
aliases: [Data Lake Gen2, ADLS, ADLS Gen2, Azure Data Lake]
billingConsiderations: [Reserved Instances]
primaryCost: "Data stored per-GB/month + index per-GB/month (HNS) + operations per-10K + data retrieval per-GB"
privateEndpoint: true
---

# Data Lake Storage Gen2

> **Trap**: Always filter by `productName` — `serviceName eq 'Storage'` alone returns Blob, Files, Queue, and Table meters. Use `Azure Data Lake Storage Gen2 Hierarchical Namespace` for HNS-enabled accounts (most ADLS deployments). `Azure Data Lake Storage Gen2 Flat Namespace` is a niche variant without directory semantics.

> **Trap (RA-GRS/RA-GZRS)**: RA-GRS shares write operation meters with GRS (e.g., `Hot GRS Write Operations`); RA-GZRS shares with GZRS. Using the GRS skuName for RA-GRS storage pricing will under-price storage but correctly price operations.

> **Trap (Default Redundancy)**: Default to **Hot LRS** unless user specifies otherwise. Always include `skuName` in filters — GRS is ~2× LRS, GZRS ~3×. Wrong redundancy row inflates cost 200–300%.

> **Trap (Tiered Calculation)**: Do NOT multiply the tier-1 rate by the full volume. The API returns separate rows with `tierMinimumUnits` 0, 51200, 512000 — each rate applies only to GB within that band. Using a single rate for all GB over-charges large volumes.

## Query Pattern

Template: `ServiceName: Storage`, `ProductName: Azure Data Lake Storage Gen2 Hierarchical Namespace`, `SkuName: {Tier} {Redundancy}`, `MeterName: {see Meter Names}`

### Hot LRS storage

ServiceName: Storage
ProductName: Azure Data Lake Storage Gen2 Hierarchical Namespace
SkuName: Hot LRS
MeterName: Hot LRS Data Stored

### Write operations (per-10K, use Quantity for scaling)

ServiceName: Storage
ProductName: Azure Data Lake Storage Gen2 Hierarchical Namespace
SkuName: Hot LRS
MeterName: Hot Write Operations
Quantity: 100

### Cool LRS storage

ServiceName: Storage
ProductName: Azure Data Lake Storage Gen2 Hierarchical Namespace
SkuName: Cool LRS
MeterName: Cool LRS Data Stored

### Cold LRS storage

ServiceName: Storage
ProductName: Azure Data Lake Storage Gen2 Hierarchical Namespace
SkuName: Cold LRS
MeterName: Cold LRS Data Stored

## Key Fields

| Parameter     | How to determine         | Example values                                                 |
| ------------- | ------------------------ | -------------------------------------------------------------- |
| `serviceName` | Always `Storage`         | `Storage`                                                      |
| `productName` | HNS vs Flat namespace    | `Azure Data Lake Storage Gen2 Hierarchical Namespace`          |
| `skuName`     | Access tier + redundancy | `Hot LRS`, `Cool ZRS`, `Cold LRS`, `Archive GRS`               |
| `meterName`   | See Meter Names          | `Hot LRS Data Stored`, `Hot LRS Index`, `Hot Write Operations` |

## Meter Names

| Meter                            | skuName         | unitOfMeasure | Notes                                         |
| -------------------------------- | --------------- | ------------- | --------------------------------------------- |
| `Hot LRS Data Stored`            | `Hot LRS`       | `1 GB/Month`  | Tiered (0-50 TB / 50-500 TB / 500+ TB)        |
| `Hot LRS Index`                  | `Hot LRS`       | `1 GB/Month`  | HNS only — directory metadata cost            |
| `Hot Write Operations`           | `Hot LRS`       | `10K`         | LRS/ZRS: no redundancy suffix                 |
| `Hot GRS Write Operations`       | `Hot GRS`       | `10K`         | GRS/RA-GRS shared                             |
| `Hot Read Operations`            | _(any Hot)_     | `10K`         | Generic, not redundancy-specific              |
| `Hot Iterative Write Operations` | `Hot LRS`       | `100`         | Directory listing; unit is per-100            |
| `Cool Data Retrieval`            | _(any Cool)_    | `1 GB`        | Per-GB retrieval; Cold tier same pattern      |
| `Cool LRS Early Delete`          | `Cool LRS`      | `1 GB`        | Deleted before 30-day minimum                 |
| `Cold LRS Data Stored`           | `Cold LRS`      | `1 GB/Month`  | Between Cool and Archive pricing              |
| `Cold LRS Early Delete`          | `Cold LRS`      | `1 GB`        | Deleted before 90-day minimum                 |
| `Archive LRS Data Stored`        | `Archive LRS`   | `1 GB/Month`  | Cheapest storage; no ZRS/GZRS                 |
| `Archive Data Retrieval`         | _(any Archive)_ | `1 GB`        | Standard rehydration                          |
| `Priority Data Retrieval`        | _(any Archive)_ | `1 GB`        | Higher-cost urgent rehydration (5x standard)  |
| `Priority Read Operations`       | _(any Archive)_ | `10K`         | Higher-cost read ops for priority rehydration |

## Cost Formula

```
Tiered storage — API returns multiple rows per meter with different tierMinimumUnits.
Tiers: 0–50 TB (0–51,200 GB) / 50–500 TB / 500+ TB (descending rate per GB).
Each tier's rate applies ONLY to GB within that band, not the entire volume.
Monthly = Σ(storage_retailPrice × GB_in_tier)
        + (index_retailPrice × indexGB)          [HNS only, Hot tier]
        + (writeOps / 10K × write_retailPrice)
        + (readOps / 10K × read_retailPrice)
        + (retrieval_retailPrice × retrievedGB)  [Cool/Cold/Archive only]
```

## Notes

- Archive tier: LRS, GRS, RA-GRS only (no ZRS/GZRS); Early Delete charges: Cool 30d, Cold 90d, Archive 180d
- Iterative operations (directory listing) use per-100 unit for writes, per-10K for reads; Hot tier only
- Flat Namespace product has identical storage pricing but no Index meter and lower transaction costs
- **Private Endpoints**: sub-resources `dfs` and `blob` (never-assume)
