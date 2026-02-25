---
serviceName: Storage
category: storage
aliases: [Managed Disks, Azure Disks, Premium SSD, Standard SSD, Ultra Disk, Disk Storage]
billingConsiderations: [Reserved Instances]
primaryCost: "Fixed monthly rate per disk (+ mount fee for Premium/Standard SSD)"
privateEndpoint: true
---

# Managed Disks

> **Trap (two-meter)**: Premium SSD returns **both** "Disk" and "Disk Mount" meters — you MUST sum both. Mount fee alone is ~5% of cost; using only mount fee = ~20× underestimate. Standard SSD returns 3 meters (Disk + Disk Mount + Operations per 10K). Standard HDD returns 2 (Disk + Operations, no mount fee). Query each meter by `MeterName` and sum with correct scaling — do not rely on `summary.totalMonthlyCost`.

> **Trap (Premium SSD v2)**: API returns two rows each for IOPS and Throughput — one at zero (free tier), one at paid rate. Use non-zero `retailPrice` and subtract: `max(0, IOPS - 3000)`, `max(0, MBps - 125)`.
> **Trap (Ultra vCPU)**: Ultra Disk has a 4th meter `Ultra LRS Reservation per vCPU Provisioned` — per vCPU on the attached VM.

## Query Pattern

### Premium SSD (e.g., P30 LRS) — substitute {Prefix}{Size} from Common SKUs

ServiceName: Storage
SkuName: P30 LRS
ProductName: Premium SSD Managed Disks
InstanceCount: 2

### Standard SSD (e.g., E30 LRS)

ServiceName: Storage
SkuName: E30 LRS
ProductName: Standard SSD Managed Disks

### Ultra Disk — provisioned (query returns capacity, IOPS, throughput, and vCPU meters)

ServiceName: Storage
SkuName: Ultra LRS
ProductName: Ultra Disks

### Premium SSD v2 — provisioned (3,000 IOPS + 125 MBps included free)

ServiceName: Storage
SkuName: Premium LRS
ProductName: Azure Premium SSD v2

> **Note**: For ZRS, replace `LRS` with `ZRS` in SkuName (Premium/Standard SSD only). Standard HDD uses `ProductName: Standard HDD Managed Disks`, `SkuName: S{Size} LRS`.

## Key Fields

| Parameter     | How to determine            | Example values                                                                                                                  |
| ------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `serviceName` | Always `Storage`            | `Storage`                                                                                                                       |
| `productName` | Disk type                   | `Premium SSD Managed Disks`, `Standard SSD Managed Disks`, `Standard HDD Managed Disks`, `Ultra Disks`, `Azure Premium SSD v2` |
| `skuName`     | {Prefix}{Size} {Redundancy} | `P30 LRS`, `P30 ZRS`, `E30 LRS`, `S30 LRS`, `Ultra LRS`, `Premium LRS`                                                        |
| `meterName`   | Meter type per disk         | `P30 LRS Disk`, `P30 LRS Disk Mount`, `E30 LRS Disk Operations`                                                                |

## Meter Names

| Disk Type      |                          Meters                          | Mount | Operations    |
| -------------- | :------------------------------------------------------: | :---: | :-----------: |
| Premium SSD    |                    Disk + Disk Mount                     |  YES  |      NO       |
| Standard SSD   | Disk + Disk Mount + Disk Operations (E4+; E1–E3 no Ops) |  YES  | YES (per 10K) |
| Standard HDD   |                  Disk + Disk Operations                  |  NO   | YES (per 10K) |
| Ultra Disk     |  Provisioned Capacity, IOPS, Throughput, vCPU Reservation |  —   |       —       |
| Premium SSD v2 |        Provisioned Capacity, IOPS, Throughput            |   —   |       —       |

## Cost Formula

- **Premium SSD**: `Monthly = (diskPrice + mountFee) × diskCount`
- **Standard SSD**: `Monthly = (diskPrice + mountFee + txnOps/10000 × opsPrice) × diskCount`
- **Standard HDD**: `Monthly = (diskPrice + txnOps/10000 × opsPrice) × diskCount`
- **Ultra Disk**: `Monthly = (GiB × capacityPrice + IOPS × iopsPrice + MBps × tputPrice + vCPUs × vcpuPrice) × 730`
- **Premium SSD v2**: `Monthly = (GiB × capacityPrice + max(0, IOPS - 3000) × iopsPrice + max(0, MBps - 125) × tputPrice) × 730`

## Notes

- Deallocating a VM does **NOT** stop disk billing — disks are billed per-disk, per-month (or per-hour for Ultra/v2)
- Premium SSD P1–P20: free credit-based bursting; P30+: on-demand burst (separate enablement + transaction meters); snapshots billed separately
- Private endpoints limited to disk import/export operations
- Standard SSD ZRS mount fee is ~12× the LRS mount fee; Premium SSD ZRS mount fee matches LRS

## Reserved Instance Pricing

Available for **Premium SSD only** (P30–P80 LRS, 1-year term). RI covers Disk meter only — mount fee remains at PAYG rate.

ServiceName: Storage
ProductName: Premium SSD Managed Disks
PriceType: Reservation

## Common SKUs

| SKU   | Size (GiB) | Max IOPS | Max MBps | Typical Use          |
| ----- | ---------- | -------- | -------- | -------------------- |
| `P4`  | 32         | 120      | 25       | Small OS disks       |
| `P10` | 128        | 500      | 100      | Dev/test             |
| `P20` | 512        | 2,300    | 150      | Medium workloads     |
| `P30` | 1,024      | 5,000    | 200      | Production databases |
| `P40` | 2,048      | 7,500    | 250      | Large databases      |
| `P50` | 4,096      | 7,500    | 250      | Data warehouses      |

> E (Standard SSD) and S (Standard HDD) follow the same size tiers (4/6/10/15/20/30/40/50/60/70/80). Substitute prefix in SKU name.
