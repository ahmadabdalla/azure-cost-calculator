---
serviceName: Storage
category: storage
aliases:
  [blob storage, file storage, table storage, queue storage, Azure Storage]
---

# Storage Accounts (Blob)

**Primary cost**: Data stored (per-GB/month), operations (per-10K), data retrieval, write operations

> **Trap**: `productName = 'Blob Storage'` only covers **LRS/GRS/RA-GRS**. For ZRS/GZRS/RA-GZRS use `productName = 'General Block Blob v2'` — wrong productName returns zero results.

> **Trap (RA-GZRS)**: RA-GZRS storage is **~25% more expensive** than GZRS but they **share** write/read operation meters (skuName `Hot GZRS`). Using GZRS skuName for RA-GZRS storage will significantly under-price.

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
Tiered pricing — API returns multiple items per meter with different tierMinimumUnits:
  0-50 TB / 50-500 TB / 500+ TB (descending price)

Monthly Total = Σ(retailPrice × GB_in_tier) + (readOps/10K × readPrice) + (writeOps/10K × writePrice)

Operation meters use tier prefix: 'Hot Read Operations', 'Cool LRS Write Operations', etc.
```

## Notes

- Read operations meter is generic (no redundancy suffix); write operations include redundancy
- RA-GZRS write operations use skuName `Hot GZRS`, not `Hot RA-GZRS`

## Product Names

| Redundancy         | productName             |
| ------------------ | ----------------------- |
| LRS, GRS, RA-GRS   | `Blob Storage`          |
| ZRS, GZRS, RA-GZRS | `General Block Blob v2` |
