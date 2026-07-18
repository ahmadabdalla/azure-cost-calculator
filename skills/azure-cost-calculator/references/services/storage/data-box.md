---
serviceName: Data Box
category: storage
aliases: [Data Box Disk, Data Box Heavy, Import/Export]
primaryCost: "Per-device service fee + shipping fee + daily overage beyond included days"
---

# Data Box

> **Trap**: serviceName is `Data Box`, NOT `Azure Data Box` (returns 0 results). Multiple productNames — plus `Data Box Gateway`, a separate service — share this serviceName; always filter by `productName`.

> **Trap (Lost/Damaged)**: Most variants expose a Lost or Damaged Device meter with very high penalty prices (Data Box Heavy has none). Exclude these one-time penalties from cost estimates.

> **Trap (Global region)**: For `Data Box` (100 TB) and `Data Box Heavy`, the service fee and extra day fee meters are priced only under `armRegionName: Global`; query the target region for shipping only.

## Query Pattern

### Data Box Disk: 3 disks

ServiceName: Data Box
ProductName: Data Box Disk
InstanceCount: 3

### Data Box (100 TB)

ServiceName: Data Box
ProductName: Data Box
SkuName: 100 TB
Region: Global # service fee + extra day fee are Global-only; query region for shipping

### Data Box V2: select skuName 120 TB or 525 TB

ServiceName: Data Box
ProductName: Data Box V2
SkuName: 120 TB

### Data Box Heavy

ServiceName: Data Box
ProductName: Data Box Heavy
Region: Global # retired product; service + extra day fees are Global-only

## Key Fields

| Parameter     | How to determine               | Example values                                                             |
| ------------- | ------------------------------ | -------------------------------------------------------------------------- |
| `serviceName` | Always `Data Box`              | `Data Box`                                                                 |
| `productName` | Device variant                 | `Data Box`, `Data Box V2`, `Data Box Disk`, `Data Box Heavy`               |
| `skuName`     | Capacity tier                  | `100 TB`, `120 TB`, `525 TB`, `Standard`                                   |
| `meterName`   | Fee component, see Meter Names | `Standard Service Fee`, `100 TB Extra Day Fee`, `Device Standard Shipping` |

## Meter Names

| Meter                             | productName      | unitOfMeasure | Notes                                                  |
| --------------------------------- | ---------------- | ------------- | ------------------------------------------------------ |
| `Standard Service Fee`            | `Data Box Disk`  | `1`           | Per order                                              |
| `Standard Daily Use Fee`          | `Data Box Disk`  | `1`           | Per disk/day; 3 included days                          |
| `Device Standard Shipping`        | `Data Box Disk`  | `1`           | Per package round-trip                                 |
| `100 TB Import Service Fee`       | `Data Box`       | `1`           | Per order; 10 included days                            |
| `100 TB Extra Day Fee`            | `Data Box`       | `1/Day`       | After included days                                    |
| `100 TB Device Standard Shipping` | `Data Box`       | `1`           | Round-trip                                             |
| `120 TB Service Fee`              | `Data Box V2`    | `1`           | Absent/zero in most regions; also `525 TB Service Fee` |
| `120 TB Extra Day Fee`            | `Data Box V2`    | `1/Day`       | Also `525 TB Extra Day Fee`                            |
| `Standard Import Service Fee`     | `Data Box Heavy` | `1`           | Per order; 20 included days                            |
| `Standard Extra Day Fee`          | `Data Box Heavy` | `1/Day`       | After included days                                    |
| `Device Standard Shipping`        | `Data Box Heavy` | `1`           | Freight round-trip                                     |

> **Note**: Data Box V2 has no shipping meter and no service fee in most regions (Microsoft-managed shipping is free); estimate V2 orders from the extra day fee only.

## Cost Formula

```
Per order = service_retailPrice + shipping_retailPrice + max(0, daysOnSite - includedDays) × extraDay_retailPrice
Disk total = (service_retailPrice + shipping_retailPrice) + daily_retailPrice × diskCount × max(0, daysOnSite - 3)
Multi-device = Per order × deviceCount
```

## Notes

- Included days before overage: Disk = 3, Data Box 100 TB = 10, V2 120 TB = 10, Heavy = 20, V2 525 TB = 20
- Data Box Disk capacity: 8 TB usable per disk, up to 5 disks per order (40 TB max)
- Data Box V2 (120 TB / 525 TB) is the current generation; Data Box Heavy is retired (no new orders) and the 100 TB device is being phased out where V2 is available
- Export orders use the same device fees; Azure Bandwidth egress charges are billed separately
- Shipping prices vary by region; always filter by the correct armRegionName
- Data Box Gateway (virtual appliance with daily compute charges) shares this serviceName but is a separate service; see `storage/data-box-gateway.md`
