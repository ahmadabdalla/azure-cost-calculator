---
serviceName: Azure Database for PostgreSQL
category: databases
aliases: [PostgreSQL, Postgres, Azure Postgres, PostgreSQL Flexible Server]
billingConsiderations: [Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/GiB-month"
privateEndpoint: true
---

# Azure Database for PostgreSQL Flexible Server

> **Trap (productName inconsistency)**: Compute products use the full `Azure Database for PostgreSQL` prefix, but storage uses the abbreviated `Az DB for PostgreSQL` prefix. Series names differ by local-disk and AMD letters (`Ddsv5`, `Dadsv5`, `Dasv6`); do not insert hyphens. Always use exact discovery strings.

> **Trap (v6 skuName)**: v6 and Confidential Compute series can use `SkuName: 1 vCore` / `MeterName: 1 vCore`, `SkuName: vCore` / `MeterName: vCore`, or only one of those patterns depending on series. Unlike v4/v5, do not assume `SkuName: N vCore`; use exact discovery and `InstanceCount` for scaling.

## Query Pattern

### Compute (General Purpose, Ddsv5 series, 4 vCores)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL Flexible Server General Purpose Ddsv5 Series Compute
SkuName: vCore
MeterName: vCore
InstanceCount: 4 # vCore count

### Compute (General Purpose, Ddsv6 series, 4 vCores)

ServiceName: Azure Database for PostgreSQL
ProductName: Azure Database for PostgreSQL Flexible Server General Purpose Ddsv6 Series Compute
SkuName: vCore
MeterName: vCore
InstanceCount: 4 # vCore count

### Storage (100 GB)

ServiceName: Azure Database for PostgreSQL
ProductName: Az DB for PostgreSQL Flexible Server Storage
SkuName: Storage
MeterName: Storage Data Stored
Quantity: 100 # storage size in GB

## Key Fields

| Parameter     | How to determine                   | Example values                                              |
| ------------- | ---------------------------------- | ----------------------------------------------------------- |
| `productName` | Tier + series (exact match)        | See Product Names table below                               |
| `skuName`     | Series-specific exact value            | `'4 vCore'`, `'vCore'`, `'1 vCore'`, `'B4ms'`               |
| `meterName`   | Compute/storage/performance component  | `'vCore'`, `'1 vCore'`, `'Storage Data Stored'`             |

## Meter Names

| Meter                                      | skuName                  | unitOfMeasure | Notes                                    |
| ------------------------------------------ | ------------------------ | ------------- | ---------------------------------------- |
| `vCore`                                    | `N vCore`, `vCore`, or VM size | `1 Hour` | GP/MO/Mdsv2 per-vCore compute           |
| `1 vCore`                                  | `1 vCore`                | `1 Hour`      | v6/Confidential per-vCore compute        |
| `B1MS`, `B2S`, `B* vCore`                  | `B1MS`, `B2S`, `B*`      | `1 Hour`      | Burstable fixed-size compute             |
| `Storage Data Stored`                      | `Storage`                | `1 GB/Month`  | Premium SSD storage                      |
| `Premium SSD v2 Storage Data Stored`       | `Premium SSD v2 Storage` | `1 GiB/Month` | Premium SSD v2 capacity                  |
| `IOPS Scaling Provisioned IOPS`            | `IOPS Scaling`           | `1/Month`     | Premium SSD extra provisioned IOPS       |
| `Premium SSD v2 IOPS Provisioned IOPS`     | `Premium SSD v2 IOPS`    | `1/Month`     | Premium SSD v2 extra provisioned IOPS    |
| `Premium SSDv2 Throughput Prov Throughput (MBps)` | `Premium SSDv2 Throughput` | `1/Month` | Premium SSD v2 extra throughput          |
| `Ultra Disk Storage Data Stored`           | `Ultra Disk Storage`     | `1 GB/Month`  | Ultra Disk capacity                      |
| `Ultra Disk IOPS Provisioned IOPS`         | `Ultra Disk IOPS`       | `1/Month` | Ultra Disk extra provisioned IOPS        |
| `Ultra Disk Throughput Prov Throughput (MBps)` | `Ultra Disk Throughput` | `1/Month` | Ultra Disk extra throughput              |
| `Backup Storage LRS Data Stored`           | `Backup Storage LRS`     | `1 GB/Month`  | Backup beyond free grant                 |

## Cost Formula

```
Monthly Compute = compute_retailPrice × 730 × vCoreCount (or fixed burstable retailPrice × 730)
Monthly Storage = storage_retailPrice × sizeGB_or_GiB
Monthly Performance = (iops_retailPrice × provisionedIOPS) + (throughput_retailPrice × provisionedMBps)
Total = Compute + Storage + optional Performance + Backup (+ HA uplift)
```

## Notes

- Burstable: dev/test workloads, does NOT support RI. Uses fixed SKU names (B1MS, B2S, B4ms, etc.)
- GP: production workloads. Selected GP series support RI; verify with `PriceType: Reservation`
- MO: high-memory workloads. Selected MO series support RI; verify with `PriceType: Reservation`
- Mdsv2 and Confidential Compute: fixed or `1 vCore` SKUs, no RI in the API
- High Availability doubles deployment costs (standby replica); no separate HA meter
- Backup storage: first backup equal to DB size is free; excess charged per-GB/month (LRS only)
- Storage options: Premium SSD (GB), Premium SSD v2 (GiB + IOPS + throughput), Ultra Disk (GB + IOPS + throughput)
- Single Server was retired in 2025; all new deployments use Flexible Server. Legacy Single Server meters still appear in the API but are not supported for new estimates
- Cosmos DB for PostgreSQL and HorizonDB meters share this serviceName; filter by productName

## Product Names

| Config              | productName                                                                            |
| ------------------- | -------------------------------------------------------------------------------------- |
| GP, Dsv3            | `Azure Database for PostgreSQL Flexible Server General Purpose Dsv3 Series Compute`    |
| GP, Ddsv4           | `Azure Database for PostgreSQL Flexible Server General Purpose Ddsv4 Series Compute`   |
| GP, Ddsv5           | `Azure Database for PostgreSQL Flexible Server General Purpose Ddsv5 Series Compute`   |
| GP, Dadsv5          | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv5 Series Compute`  |
| GP, Ddsv6           | `Azure Database for PostgreSQL Flexible Server General Purpose Ddsv6 Series Compute`   |
| GP, Dadsv6          | `Azure Database for PostgreSQL Flexible Server General Purpose Dadsv6 Series Compute`  |
| GP, Dsv6            | `Azure Database for PostgreSQL Flexible Server General Purpose Dsv6 Series Compute`    |
| GP, Dasv6           | `Azure Database for PostgreSQL Flexible Server General Purpose Dasv6 Series Compute`   |
| MO, Esv3            | `Azure Database for PostgreSQL Flexible Server Memory Optimized Esv3 Series Compute`   |
| MO, Edsv4           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv4 Series Compute`  |
| MO, Edsv5           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv5 Series Compute`  |
| MO, Eadsv5          | `Azure Database for PostgreSQL Flexible Server Memory Optimized Eadsv5 Series Compute` |
| MO, Ebdsv5          | `Azure Database for PostgreSQL Flexible Server Memory Optimized Ebdsv5 Series Compute` |
| MO, Edsv6           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Edsv6 Series Compute`  |
| MO, Eadsv6          | `Azure Database for PostgreSQL Flexible Server Memory Optimized Eadsv6 Series Compute` |
| MO, Esv6            | `Azure Database for PostgreSQL Flexible Server Memory Optimized Esv6 Series Compute`   |
| MO, Easv6           | `Azure Database for PostgreSQL Flexible Server Memory Optimized Easv6 Series Compute`  |
| Mdsv2               | `Azure Database for PostgreSQL Flexible Server Mdsv2 Series Compute`                   |
| Conf, DCadsv5       | `Azure Database for PostgreSQL Flexible Server Confidential Compute DCadsv5 Series Compute` |
| Conf, DCadsv6       | `Azure Database for PostgreSQL Flexible Server Confidential Compute DCadsv6 Series Compute` |
| Conf, DCasv5        | `Azure Database for PostgreSQL Flexible Server Confidential Compute DCasv5 Series Compute` |
| Conf, DCesv6        | `Azure Database for PostgreSQL Flexible Server Confidential Compute DCesv6 Series Compute` |
| Conf, ECadsv5       | `Azure Database for PostgreSQL Flexible Server Confidential Compute ECadsv5 Series Compute` |
| Conf, ECadsv6       | `Azure Database for PostgreSQL Flexible Server Confidential Compute ECadsv6 Series Compute` |
| Conf, ECasv5        | `Azure Database for PostgreSQL Flexible Server Confidential Compute ECasv5 Series Compute` |
| Conf, ECesv6        | `Azure Database for PostgreSQL Flexible Server Confidential Compute ECesv6 Series Compute` |
| Burstable, BS       | `Azure Database for PostgreSQL Flexible Server Burstable BS Series Compute`            |
| Storage             | `Az DB for PostgreSQL Flexible Server Storage`                                         |
| Backup              | `Azure Database for PostgreSQL Flexible Server Backup Storage`                         |
