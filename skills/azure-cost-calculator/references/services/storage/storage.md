---
serviceName: Storage
category: storage
aliases: [Blob Storage, Azure Files, Table Storage, Queue Storage, Azure Storage]
billingConsiderations: [Reserved Instances]
primaryCost: "Data stored per-GB/month (tiered) + operations per-10K + data retrieval per-GB"
privateEndpoint: true
---

# Storage

> **Trap**: `productName = 'Blob Storage'` only covers **LRS/GRS/RA-GRS**. For ZRS/GZRS/RA-GZRS use `productName = 'General Block Blob v2'`; wrong productName returns zero results.

> **Trap (RA-GZRS)**: Hot/Cool RA-GZRS has **no Write Operations meter**; query with GZRS skuName instead (e.g., `Hot GZRS` + `Hot GZRS Write Operations`). RA-GRS similarly uses GRS write meter names. Data stored meters exist for all RA- variants at higher prices (~25% over non-RA).

> **Trap (Default Redundancy)**: Default to **Hot LRS** unless user explicitly requests otherwise. Always include `skuName` in filters; GRS is ~2× LRS, RA-GZRS ~3×. Wrong redundancy row inflates cost 200–300%.

> **Trap (Tiered Calculation)**: Do NOT multiply the tier-1 rate by the full volume. Hot tier returns 3 rows with `tierMinimumUnits` 0, 51200, 512000; each rate applies only to GB within that band. Cool, Cold, and Archive use flat rates.

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
Hot tier: tiered; rows with tierMinimumUnits 0, 51200, 512000 GB.
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
- Early delete: Cool 30d, Cold 90d, Archive 180d; rate equals data stored rate, prorated
- Archive tier: LRS/GRS/RA-GRS only (no ZRS/GZRS/RA-GZRS); Cold tier has no Reserved Instances
- PE sub-resources (never-assume): `blob`, `file`, `queue`, `table`, `dfs`, `web`. Secondary variants (`blob_secondary`, etc.) for RA-GRS/RA-GZRS.
- Sub-products (see Product Names): Files ops use `LRS Write/Read/Protocol Operations` + a separate `LRS Metadata` (per-GB) meter; Tables (`Write/Read/Scan Operations`) and Queues (`Class 1 Operations`, `Class 2 Operations`) are sub-cent per-10K. Legacy `Files`/`Queues` productNames apply to GPv1 accounts

## Reserved Instance Pricing

Reserved capacity discounts Blob (Hot/Cool/Archive) and Azure Files data at fixed commitments (Blob: 100 TB / 1 PB / 10 PB; Files: 10 TB / 100 TB), 1-Year or 3-Year terms (set via `reservationTerm`). Billed under `Storage Reserved Capacity` (Blob), `Files Reserved Capacity`, or `Premium Files Reserved Capacity` — distinct from PAYG productNames. Not available for Cold tier, Tables, or Queues.

> **Trap (RI MonthlyCost)**: The script's `MonthlyCost` is wrong for Reservation items; it multiplies the full term price by 730. Calculate `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year).

ServiceName: Storage
ProductName: Storage Reserved Capacity
SkuName: Hot - 100 TB LRS
PriceType: Reservation

## Product Names

| Sub-product / Redundancy    | productName             | Default skuName | Data Stored meter       |
| --------------------------- | ----------------------- | --------------- | ----------------------- |
| Blob LRS, GRS, RA-GRS       | `Blob Storage`          | `Hot LRS`       | `Hot LRS Data Stored`   |
| Blob ZRS, GZRS, RA-GZRS     | `General Block Blob v2` | `Hot ZRS`       | `Hot ZRS Data Stored`   |
| Blob Premium LRS/ZRS        | `Premium Block Blob`    | `Premium LRS`   | `Premium LRS Data Stored` |
| Azure Files (pay-as-you-go) | `Files v2`              | `Standard LRS`  | `LRS Data Stored`       |
| Azure Files (provisioned)   | `Premium Files`         | `Premium LRS`   | `Premium LRS Provisioned` |
| Table Storage               | `Tables`                | `Standard LRS`  | `LRS Data Stored`       |
| Queue Storage               | `Queues v2`             | `Standard LRS`  | `LRS Data Stored`       |
