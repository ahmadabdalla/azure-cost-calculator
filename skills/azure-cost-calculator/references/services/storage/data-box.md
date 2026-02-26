---
serviceName: Data Box
category: storage
aliases: [Data Box Disk, Data Box Heavy, Import/Export]
primaryCost: "Per-device service fee + shipping fee + daily overage beyond included days"
---

# Azure Data Box

> **Trap**: serviceName is `Data Box` — NOT `Azure Data Box` (returns 0 results). Multiple productNames exist under this serviceName; always filter by `productName` to target a specific variant.

> **Trap (Lost/Damaged)**: Each variant includes a Lost or Damaged Device meter with very high penalty prices. Exclude these from cost estimates — they are one-time penalty charges, not recurring costs.

## Query Pattern

### Data Box Disk — 3 disks

ServiceName: Data Box
ProductName: Data Box Disk
InstanceCount: 3

### Data Box (100 TB)

ServiceName: Data Box
ProductName: Data Box
SkuName: 100 TB

### Data Box V2 — select skuName 120 TB or 525 TB

ServiceName: Data Box
ProductName: Data Box V2
SkuName: 120 TB

### Data Box Heavy

ServiceName: Data Box
ProductName: Data Box Heavy

## Key Fields

| Parameter     | How to determine                | Example values                                                             |
| ------------- | ------------------------------- | -------------------------------------------------------------------------- |
| `serviceName` | Always `Data Box`               | `Data Box`                                                                 |
| `productName` | Device variant                  | `Data Box`, `Data Box V2`, `Data Box Disk`, `Data Box Heavy`               |
| `skuName`     | Capacity tier                   | `100 TB`, `120 TB`, `525 TB`, `Standard`                                   |
| `meterName`   | Fee component — see Meter Names | `Standard Service Fee`, `100 TB Extra Day Fee`, `Device Standard Shipping` |

## Meter Names

| Meter                             | productName      | unitOfMeasure | Notes                                |
| --------------------------------- | ---------------- | ------------- | ------------------------------------ |
| `Standard Service Fee`            | `Data Box Disk`  | `1`           | Per order                            |
| `Standard Daily Use Fee`          | `Data Box Disk`  | `1`           | Per disk/day; 3 included days        |
| `Device Standard Shipping`        | `Data Box Disk`  | `1`           | Per package round-trip               |
| `100 TB Import Service Fee`       | `Data Box`       | `1`           | Per order; 10 included days          |
| `100 TB Extra Day Fee`            | `Data Box`       | `1/Day`       | After included days                  |
| `100 TB Device Standard Shipping` | `Data Box`       | `1`           | Round-trip                           |
| `120 TB Service Fee`              | `Data Box V2`    | `1`           | Per order; also `525 TB Service Fee` |
| `120 TB Extra Day Fee`            | `Data Box V2`    | `1/Day`       | Also `525 TB Extra Day Fee`          |
| `Standard Import Service Fee`     | `Data Box Heavy` | `1`           | Per order; 20 included days          |
| `Standard Extra Day Fee`          | `Data Box Heavy` | `1/Day`       | After included days                  |
| `Device Standard Shipping`        | `Data Box Heavy` | `1`           | Freight round-trip                   |

Data Box V2 has no shipping meter in the API — shipping may be bundled into the service fee.

## Cost Formula

```
Per order = service_retailPrice + shipping_retailPrice + max(0, daysOnSite - includedDays) × extraDay_retailPrice
Disk total = (service_retailPrice + shipping_retailPrice) + daily_retailPrice × diskCount × max(0, daysOnSite - 3)
Multi-device = Per order × deviceCount
```

## Notes

- Included days before overage: Disk = 3, Data Box 100 TB = 10, V2 120 TB = 10, Heavy = 20, V2 525 TB = 20
- Data Box Disk capacity: 8 TB usable per disk, up to 5 disks per order (40 TB max)
- Data Box V2 (120 TB / 525 TB) is the newer generation with higher overage rates
- Export orders use the same device fees; Azure Bandwidth egress charges are billed separately
- Shipping prices vary by region — always filter by the correct armRegionName
- Data Box Gateway (virtual appliance with daily compute charges) shares this serviceName but is not an offline transfer device
