---
serviceName: Storage
category: storage
aliases: [Data Lake Gen2, ADLS, ADLS Gen2, Azure Data Lake]
billingConsiderations: [Reserved Instances]
primaryCost: "Data stored per-GB/month + index per-GB/month (HNS) + operations per-10K + data retrieval per-GB"
privateEndpoint: true
---

# Data Lake Storage Gen2

> **Trap**: Always filter by `productName`; `serviceName eq 'Storage'` alone returns Blob, Files, Queue, and Table meters. Use `Azure Data Lake Storage Gen2 Hierarchical Namespace` for HNS-enabled accounts (most ADLS deployments). `Azure Data Lake Storage Gen2 Flat Namespace` is a niche variant without directory semantics.

> **Trap (RA-GRS/RA-GZRS)**: RA-GRS shares write operation meters with GRS (e.g., `Hot GRS Write Operations`); RA-GZRS shares with GZRS. Using the GRS skuName for RA-GRS storage pricing will under-price storage but correctly price operations.

> **Trap (Default Redundancy)**: Default to **Hot LRS** unless user specifies otherwise. Always include `skuName` in filters; GRS is ~2× LRS, GZRS ~3×. Wrong redundancy row inflates cost 200–300%.

> **Trap (Tiered Calculation)**: Do NOT multiply the tier-1 rate by the full volume. The API returns separate rows with `tierMinimumUnits` 0, 51200, 512000; each rate applies only to GB within that band. Using a single rate for all GB over-charges large volumes.

> **Trap (Sub-cent Operations)**: Many operation meters and Archive/Cold storage meters return sub-cent `retailPrice`; the script may round the display to zero. Never report zero cost — use the API `retailPrice` directly. `Hot Iterative Write Operations` uses a `100` unit (per-100, not per-10K); divide the op count by 100.

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
| `Hot LRS Index`                  | `Hot LRS`       | `1 GB/Month`  | HNS only, directory metadata cost            |
| `Hot Write Operations`           | `Hot LRS`       | `10K`         | LRS only: no suffix; ZRS/GRS/GZRS use suffix   |
| `Hot GRS Write Operations`       | `Hot GRS`       | `10K`         | GRS/RA-GRS shared                             |
| `Hot Read Operations`            | _(any Hot)_     | `10K`         | Generic, not redundancy-specific              |
| `Hot Other Operations`           | _(any Hot)_     | `10K`         | Metadata ops (GetProperties, SetMetadata)     |
| `Hot Iterative Write Operations` | `Hot LRS`       | `100`         | Directory/path rename; unit is per-100        |
| `Cool Data Retrieval`            | _(any Cool)_    | `1 GB`        | Per-GB retrieval charge                       |
| `Cool LRS Data Stored`           | `Cool LRS`      | `1 GB/Month`  | Flat rate (no tiers unlike Hot)               |
| `Cold LRS Data Stored`           | `Cold LRS`      | `1 GB/Month`  | Between Cool and Archive pricing              |
| `Archive LRS Data Stored`        | `Archive LRS`   | `1 GB/Month`  | Cheapest storage; no ZRS/GZRS                 |
| `Archive Data Retrieval`         | _(any Archive)_ | `1 GB`        | Standard rehydration                          |
| `Priority Data Retrieval`        | _(any Archive)_ | `1 GB`        | Higher-cost urgent rehydration (5x standard)  |
| `Priority Read Operations`       | _(any Archive)_ | `10K`         | Higher-cost read ops for priority rehydration |

## Cost Formula

```
Tiered storage: API returns multiple rows per meter with different tierMinimumUnits.
Tiers: 0–50 TB (0–51,200 GB) / 50–500 TB / 500+ TB (descending rate per GB).
Each tier's rate applies ONLY to GB within that band, not the entire volume.
Monthly = Σ(storage_retailPrice × GB_in_tier)
        + (index_retailPrice × indexGB)          [HNS only, Hot tier]
        + (writeOps / 10K × write_retailPrice)
        + (readOps / 10K × read_retailPrice)
        + (retrieval_retailPrice × retrievedGB)  [Cool/Cold/Archive only]
```

## Notes

- Archive tier: LRS, GRS, RA-GRS only (no ZRS/GZRS); Early Delete charges: Cool 30d, Cold 90d, Archive 180d. Cool GZRS/RA-GZRS have no Early Delete meter
- Iterative operations: per-100 unit for writes (Rename ops), per-10K for reads (listing); Hot tier only
- Flat Namespace product has identical storage pricing but no Index meter and lower transaction costs
- Storage bills in binary GiB: the API `1 GB/Month` unit is 1 GiB (2³⁰ bytes), so 1 TB = 1,024 billing GB (per the ADLS pricing page)
- **Private Endpoints**: sub-resources `dfs` and `blob` (never-assume); see `networking/private-link.md` for PE and DNS zone pricing

## Reserved Instance Pricing

Azure Storage reserved capacity discounts ADLS Gen2 Hot/Cool/Archive data at 100 TB, 1 PB, or 10 PB commitments (1-Year and 3-Year terms; set via `reservationTerm`). Billed under the `Storage Reserved Capacity` product (not the PAYG productName); the reservation applies automatically to eligible usage. Reservation `retailPrice` is the total commitment cost, not a per-month rate.

ServiceName: Storage
ProductName: Storage Reserved Capacity
SkuName: Hot - 100 TB LRS
PriceType: Reservation
