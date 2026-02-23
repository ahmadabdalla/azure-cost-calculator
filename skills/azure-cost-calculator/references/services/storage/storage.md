---
serviceName: Storage
category: storage
aliases: [Blob Storage, Azure Files, Table Storage, Queue Storage]
billingConsiderations: [Reserved Instances]
primaryCost: "Data stored per-GB/month (tiered) + operations per-10K + data retrieval per-GB"
privateEndpoint: true
---

# Storage Accounts (Blob)

> **Trap**: `productName = 'Blob Storage'` only covers **LRS/GRS/RA-GRS**. For ZRS/GZRS/RA-GZRS use `productName = 'General Block Blob v2'` — wrong productName returns zero results.

> **Trap (RA-GZRS)**: RA-GZRS storage is **~25% more expensive** than GZRS but they **share** write/read operation meters (skuName `Hot GZRS`). Using GZRS skuName for RA-GZRS storage will significantly under-price.

> **Trap (Default Redundancy)**: Default to **Hot LRS** unless user explicitly requests otherwise. Always include `skuName` in filters — GRS is ~2× LRS, RA-GZRS ~3×. Wrong redundancy row inflates cost 200–300%.

> **Trap (Tiered Calculation)**: Do NOT multiply the tier-1 rate by the full volume. The API returns separate rows with `tierMinimumUnits` 0, 51200, 512000 — each rate applies only to GB within that band. Using a single rate for all GB over-charges large volumes.

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

## Key Fields

| Parameter     | How to determine         | Example values                               |
| ------------- | ------------------------ | -------------------------------------------- |
| `serviceName` | Always `Storage`         | `Storage`                                    |
| `skuName`     | Access tier + redundancy | `Hot LRS`, `Cool ZRS`, `Hot RA-GZRS`         |
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
| `Hot GZRS Write Operations` | `Hot GZRS`    | `General Block Blob v2` | `10K`         | Shared by GZRS & RA-GZRS         |

Meter pattern: `{Tier} {Redundancy} Data Stored`, `{Tier} Read Operations`, `{Tier} {Redundancy} Write Operations`

## Cost Formula

```
Tiered pricing — API returns multiple rows per meter with different tierMinimumUnits.
Tiers: 0–50 TB (0–51,200 GB) / 50–500 TB / 500+ TB (descending rate per GB).
Each tier's rate applies ONLY to GB within that band, not the entire volume.

Example: 60 TB (61,440 GB) Hot LRS →
  Tier 1: 51,200 GB × tier1_retailPrice
  Tier 2: 10,240 GB × tier2_retailPrice  (61,440 − 51,200)
  Total storage = sum of both tiers

Monthly = Σ(retailPrice × GB_in_tier) + (readOps/10K × readPrice) + (writeOps/10K × writePrice)
```

## Notes

- Read operations meter is generic (no redundancy suffix); write operations include redundancy
- RA-GZRS write operations use skuName `Hot GZRS`, not `Hot RA-GZRS`
- PE sub-resources (never-assume): `blob`, `file`, `queue`, `table`, `dfs`, `web`. Secondary variants (`blob_secondary`, etc.) apply only with RA-GRS/RA-GZRS.

## Product Names

| Redundancy         | productName             |
| ------------------ | ----------------------- |
| LRS, GRS, RA-GRS   | `Blob Storage`          |
| ZRS, GZRS, RA-GZRS | `General Block Blob v2` |
