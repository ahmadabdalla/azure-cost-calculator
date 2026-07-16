---
serviceName: Azure Database for MySQL
category: databases
aliases: [MySQL, Azure MySQL, MySQL Flexible Server]
billingConsiderations: [Reserved Instances]
primaryCost: "vCore hours × 730 + storage/IOPS/backup usage"
privateEndpoint: true
---

# Azure Database for MySQL Flexible Server

> **Trap**: Unfiltered queries return Flexible Server, retired Single Server, Extended Support, storage, backup, and add-on meters. Filter by `ProductName` and `MeterName`.
>
> **Trap (vCore meters)**: Most per-vCore series return `SkuName: 'vCore'` and `SkuName: '1 vCore'`; use `SkuName: vCore` with `InstanceCount`. Business Critical Ev3 uses `SkuName: 1 vCore`.

## Query Pattern

### Compute: General Purpose (Ddsv5, 4 vCores)
ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server General Purpose Ddsv5 Series Compute
SkuName: vCore
MeterName: vCore
InstanceCount: 4 # vCore count

### Storage (100 GB)
ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server Storage
SkuName: Storage
MeterName: Storage Data Stored
Quantity: 100 # storage size in GB

### Additional IOPS (100 provisioned IOPS)
ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server Storage
SkuName: Additional IOPS
MeterName: Additional IOPS
Quantity: 100 # provisioned IOPS

### Backup storage (100 GB beyond free grant)
ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server Backup Storage
SkuName: Backup Storage LRS
MeterName: Backup Storage LRS Data Stored
Quantity: 100 # billable backup GB

## Key Fields
| Parameter     | How to determine                                                        | Example values                              |
| ------------- | ----------------------------------------------------------------------- | ------------------------------------------- |
| `productName` | Tier + series or storage family (exact match)                           | See Product Names below                     |
| `skuName`     | Per-vCore: `'vCore'`; Business Critical: `'1 vCore'`; fixed tiers: SKU  | `'vCore'`, `'1 vCore'`, `'Standard_B4ms'`   |
| `meterName`   | Compute, storage, IOPS, backup, or add-on meter                         | `'vCore'`, `'Additional IOPS'`, `'B4MS'`    |

## Meter Names
| Meter                                  | skuName              | unitOfMeasure | Notes                                  |
| -------------------------------------- | -------------------- | ------------- | -------------------------------------- |
| `vCore`                                | `vCore`              | `1 Hour`      | Per-vCore GP/MO/Confidential           |
| `vCore`                                | `1 vCore`            | `1 Hour`      | Business Critical Ev3                  |
| `B4MS`                                 | `Standard_B4ms`      | `1 Hour`      | Fixed Burstable SKU                    |
| `Storage Data Stored`                  | `Storage`            | `1 GB/Month`  | Standard LRS storage                   |
| `Storage ZRS Data Stored`              | `Storage ZRS`        | `1 GB/Month`  | Standard ZRS storage                   |
| `Additional IOPS`                      | `Additional IOPS`    | `1 IOPS/Month` | Pre-provisioned extra IOPS            |
| `Paid IO LRS IO Rate Operations`       | `Paid IO LRS`        | `1M`          | Autoscale I/O per million operations   |
| `SSD v2 Data Stored`                   | `SSD v2`             | `1 GiB/Month` | SSD v2 storage                         |
| `SSD v2 IOPS Provisioned IOPS`         | `SSD v2 IOPS`        | `1/Month`     | SSD v2 provisioned IOPS                |
| `Backup Storage LRS Data Stored`       | `Backup Storage LRS` | `1 GB/Month`  | Backup beyond free grant               |
| `Storage GP Accelerated Logs`          | `Storage GP Accelerated Logs` | `1 Hour` | GP accelerated logs add-on             |

## Cost Formula

```
Compute (per-vCore) = compute_retailPrice × 730 × vCoreCount
Compute (Burstable/Edsv5) = compute_retailPrice × 730
Storage = storage_retailPrice × sizeGBOrGiB
Provisioned IOPS/throughput = meter_retailPrice × quantity
Autoscale I/O = io_retailPrice × (operations / 1,000,000)
Backup = backup_retailPrice × max(0, backupGB - provisionedStorageGB)
Total = Compute + Storage + optional IOPS/throughput + optional Backup
```

## Notes
- Microsoft Learn names current tiers Burstable, General Purpose, and Memory-Optimized; API also returns Business Critical Ev3. Burstable and Business Critical Ev3 have no RI meters.
- RI exists for specific GP/MO/Confidential products only; disk-attached v6 products (`Ddsv6`, `Dadsv6`, `Edsv6`, `Eadsv6`) return no RI meters.
- HA doubles compute cost; backup equal to provisioned storage is free; Single Server is retired but meters and Extended Support remain in API.
- Accelerated logs are billed for GP, included for Memory-Optimized, and unsupported for Burstable.

## Reserved Instance Pricing

### RI for GP Flexible Server (generic series, per-vCore)
ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server General Purpose Series Compute
SkuName: vCore
MeterName: vCore
PriceType: Reservation

> **Trap (RI exclusions)**: Burstable, Business Critical Ev3, MO Edsv5 fixed-size, and disk-attached v6 products do NOT support RI. Monthly cost: `unitPrice ÷ 12 × vCoreCount` (1-Year) or `unitPrice ÷ 36 × vCoreCount` (3-Year).

## Product Names
| Config             | productName                                                                       |
| ------------------ | --------------------------------------------------------------------------------- |
| GP, Ddsv5          | `Azure Database for MySQL Flexible Server General Purpose Ddsv5 Series Compute`   |
| GP, Dadsv5         | `Azure Database for MySQL Flexible Server General Purpose Dadsv5 Series Compute`  |
| GP, Ddsv6          | `Azure Database for MySQL Flexible Server General Purpose Ddsv6 Series Compute`   |
| GP, Dadsv6         | `Azure Database for MySQL Flexible Server General Purpose Dadsv6 Series Compute`  |
| GP, Dsv6           | `Azure Database for MySQL Flexible Server General Purpose Dsv6 Series Compute`    |
| GP, Dasv6          | `Azure Database for MySQL Flexible Server General Purpose Dasv6 Series Compute`   |
| GP, generic RI     | `Azure Database for MySQL Flexible Server General Purpose Series Compute`         |
| BC, Ev3            | `Azure Database for MySQL Flexible Server Business Critical Ev3 Series Compute`   |
| MO, Edsv5          | `Azure Database for MySQL Flexible Server Memory Optimized Edsv5 Series Compute`  |
| MO, Eadsv5         | `Azure Database for MySQL Flexible Server Memory Optimized Eadsv5 Series Compute` |
| MO, Edsv6          | `Azure Database for MySQL Flexible Server Memory Optimized Edsv6 Series Compute`  |
| MO, Eadsv6         | `Azure Database for MySQL Flexible Server Memory Optimized Eadsv6 Series Compute` |
| MO, Esv6           | `Azure Database for MySQL Flexible Server Memory Optimized Esv6 Series Compute`   |
| MO, Easv6          | `Azure Database for MySQL Flexible Server Memory Optimized Easv6 Series Compute`  |
| MO, generic RI     | `Azure Database for MySQL Flexible Server Memory Optimized Series Compute`        |
| Confidential       | `Azure Database for MySQL Flexible Server Confidential Compute ECadsv6 Series`    |
| Burstable, BS      | `Azure Database for MySQL Flexible Server Burstable BS Series Compute`            |
| Storage            | `Azure Database for MySQL Flexible Server Storage`                                |
| Backup             | `Azure Database for MySQL Flexible Server Backup Storage`                         |
