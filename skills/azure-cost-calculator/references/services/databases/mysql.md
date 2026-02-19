---
serviceName: Azure Database for MySQL
category: databases
aliases: [MySQL, Azure MySQL]
billingConsiderations: [Reserved Instances]
primaryCost: "vCore hourly rate × 730 + storage per-GB/month"
privateEndpoint: true
---

# Azure Database for MySQL Flexible Server

> **Trap**: Unfiltered queries return ~80 meters across deprecated Single Server, all Flexible Server series, and storage — wildly inflated total. Always filter by `ProductName` to target one series.

> **Trap (dual vCore meters)**: Newer series (v5/v6) return two identical per-vCore meters — `SkuName: 'vCore'` and `SkuName: '1 vCore'`. Use `SkuName: vCore` with `InstanceCount` for vCore count.

> **Trap (RI MonthlyCost)**: The script's MonthlyCost multiplies the full term price by 730 — always manually calculate: `unitPrice ÷ 12` (1-Year) or `unitPrice ÷ 36` (3-Year).

## Query Pattern

### Compute — General Purpose (Ddsv5, 4 vCores)

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

### Compute — Burstable (B4MS)

ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server Burstable BS Series Compute
SkuName: Standard_B4ms
MeterName: B4MS

### Compute — Memory Optimized (Edsv5, 8 vCores)

ServiceName: Azure Database for MySQL
ProductName: Azure Database for MySQL Flexible Server Memory Optimized Edsv5 Series Compute
SkuName: Standard_E8d_v5
MeterName: 8 vCore

## Key Fields

| Parameter     | How to determine                                                       | Example values                   |
| ------------- | ---------------------------------------------------------------------- | -------------------------------- |
| `productName` | Tier + series (exact match)                                            | See Product Names below          |
| `skuName`     | Per-vCore series: `'vCore'`; Burstable: SKU name; Edsv5: `Standard_E*` | `'vCore'`, `'Standard_B4ms'`     |
| `meterName`   | Per-vCore: `'vCore'`; Burstable: SKU code; Edsv5: `'N vCore'`          | `'vCore'`, `'B4MS'`, `'8 vCore'` |

## Meter Names

| Meter                            | skuName              | unitOfMeasure | Notes                                                        |
| -------------------------------- | -------------------- | ------------- | ------------------------------------------------------------ |
| `vCore`                          | `vCore`              | `1 Hour`      | Per-vCore rate — multiply via InstanceCount (GP/BC/MO v5/v6) |
| `B4MS`                           | `Standard_B4ms`      | `1 Hour`      | Fixed Burstable SKU — includes vCPU+RAM                      |
| `8 vCore`                        | `Standard_E8d_v5`    | `1 Hour`      | Fixed MO Edsv5 size — includes vCPU+RAM                      |
| `Storage Data Stored`            | `Storage`            | `1 GB/Month`  | Data storage                                                 |
| `Backup Storage LRS Data Stored` | `Backup Storage LRS` | `1 GB/Month`  | Backup storage (LRS redundancy)                              |

## Cost Formula

```
Compute (per-vCore series) = compute_retailPrice × 730 × vCoreCount
Compute (Burstable / Edsv5) = compute_retailPrice × 730
Storage = storage_retailPrice × sizeGB
Total = Compute + Storage
```

## Notes

- Burstable: dev/test workloads, does NOT support RI, max 20 vCores
- GP: production workloads, supports RI, per-vCore pricing with InstanceCount
- MO Edsv5: high-memory workloads, per-size SKU pricing (Standard_E2d_v5 through Standard_E96d_v5)
- High Availability doubles compute cost (deploys a standby replica)
- Backup: first backup equal to provisioned storage is free; excess charged per-GB/month
- Single Server is deprecated — all new deployments use Flexible Server
- Supports private endpoints — see `networking/private-link.md` for PE and DNS zone pricing

## Product Names

| Config        | productName                                                                       |
| ------------- | --------------------------------------------------------------------------------- |
| GP, Ddsv5     | `Azure Database for MySQL Flexible Server General Purpose Ddsv5 Series Compute`   |
| GP, Dadsv5    | `Azure Database for MySQL Flexible Server General Purpose Dadsv5 Series Compute`  |
| GP, Dv3       | `Azure Database for MySQL Flexible Server General Purpose Dv3 Series Compute`     |
| MO, Edsv5     | `Azure Database for MySQL Flexible Server Memory Optimized Edsv5 Series Compute`  |
| MO, Eadsv5    | `Azure Database for MySQL Flexible Server Memory Optimized Eadsv5 Series Compute` |
| BC, Ev3       | `Azure Database for MySQL Flexible Server Business Critical Ev3 Series Compute`   |
| Burstable, BS | `Azure Database for MySQL Flexible Server Burstable BS Series Compute`            |
| Storage       | `Azure Database for MySQL Flexible Server Storage`                                |
| Backup        | `Azure Database for MySQL Flexible Server Backup Storage`                         |
