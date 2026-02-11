---
serviceName: Storage
category: storage
aliases: [managed disks, disks, disk storage]
---

# Managed Disks

**Primary cost**: Fixed monthly rate per disk (+ mount fee for Premium/Standard SSD)

> **Trap (meter count varies by type)**: Premium SSD returns 2 meters (Disk + Disk Mount). Standard SSD returns 3 (Disk + Disk Mount + Disk Operations). Standard HDD returns 2 (Disk + Disk Operations — **no** mount fee). The `summary.totalMonthlyCost` sums all meters correctly — but present them separately for transparency.

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

### Ultra Disk — provisioned (query returns capacity, IOPS, and throughput meters)

ServiceName: Storage
SkuName: Ultra LRS
ProductName: Ultra Disks

### Premium SSD v2 — provisioned (3,000 IOPS + 125 MBps included free)

ServiceName: Storage
SkuName: Premium LRS
ProductName: Azure Premium SSD v2

> **ZRS**: For Premium/Standard SSD, replace `LRS` with `ZRS` in SkuName (~50% more). HDD is LRS only.
> **Standard HDD**: Use `ProductName: Standard HDD Managed Disks`, `SkuName: S{Size} LRS`.

## Meters per Disk Type

| Disk Type      |                           Disk                           | Disk Mount | Disk Operations |
| -------------- | :------------------------------------------------------: | :--------: | :-------------: |
| Premium SSD    |                           YES                            |    YES     |       NO        |
| Standard SSD   |                           YES                            |    YES     |  YES (per 10K)  |
| Standard HDD   |                           YES                            |     NO     |  YES (per 10K)  |
| Ultra Disk     | Provisioned Capacity, IOPS, Throughput, vCPU Reservation |     —      |        —        |
| Premium SSD v2 |          Provisioned Capacity, IOPS, Throughput          |     —      |        —        |

> **Trap (Premium SSD v2 free tier)**: The API returns **two rows** each for IOPS and Throughput — one at $0.00 (the included 3,000 IOPS / 125 MBps) and one at the paid rate. Use the non-zero price and subtract free units: `max(0, IOPS - 3000)` and `max(0, MBps - 125)`.
> **Trap (Ultra vCPU charge)**: Ultra Disk returns a 4th meter `Ultra LRS Reservation per vCPU Provisioned` — billed per vCPU on the attached VM.

## Key Fields

| Parameter     | How to determine        | Example values                                                                                   |
| ------------- | ----------------------- | ------------------------------------------------------------------------------------------------ |
| `productName` | Disk type               | `Premium SSD Managed Disks`, `Standard SSD Managed Disks`, `Ultra Disks`, `Azure Premium SSD v2` |
| `skuName`     | Disk size + redundancy  | `P30 LRS`, `P30 ZRS`, `E30 LRS`, `S30 LRS`, `Ultra LRS`, `Premium LRS`                           |
| `meterName`   | Specific cost component | `P30 LRS Disk`, `P30 LRS Disk Mount`, `E30 LRS Disk Operations`                                  |

## Cost Formula

**Premium SSD**: `Monthly = (diskPrice + mountFee) × diskCount`

**Standard SSD**: `Monthly = (diskPrice + mountFee + txnOps/10000 × opsPrice) × diskCount`

**Standard HDD**: `Monthly = (diskPrice + txnOps/10000 × opsPrice) × diskCount`

**Ultra Disk**: `Monthly = (GiB × capacityPrice + IOPS × iopsPrice + MBps × tputPrice + vCPUs × vcpuPrice) × 730`

**Premium SSD v2**: `Monthly = (GiB × capacityPrice + max(0, IOPS - 3000) × iopsPrice + max(0, MBps - 125) × tputPrice) × 730`

## Reserved Instance Pricing

Available for **Premium SSD only** (1-year). Query with `-PriceType Reservation`.

> **RI MonthlyCost trap** — see shared.md & Reserved Instance MonthlyCost.

## Common SKUs

| SKU   | Size (GiB) | Max IOPS | Max MBps | Typical Use          |
| ----- | ---------- | -------- | -------- | -------------------- |
| `P4`  | 32         | 120      | 25       | Small OS disks       |
| `P6`  | 64         | 240      | 50       | Light workloads      |
| `P10` | 128        | 500      | 100      | Dev/test             |
| `P20` | 512        | 2,300    | 150      | Medium workloads     |
| `P30` | 1,024      | 5,000    | 200      | Production databases |
| `P40` | 2,048      | 7,500    | 250      | Large databases      |
| `P50` | 4,096      | 7,500    | 250      | Data warehouses      |

> E (Standard SSD) and S (Standard HDD) follow the same size tiers (4/6/10/15/20/30/40/50/60/70/80). Substitute prefix in SKU name.

## Notes

- Deallocating a VM does **NOT** stop disk billing — disks billed per-disk, per-month.
- Premium SSD P1–P20 include free burst (up to 3,500 IOPS / 170 MBps). On-demand burst for P20+ is a separate meter.
- Snapshots billed separately (`Managed Disk Snapshots`). Ultra/Premium SSD v2 have per-vCPU reservation charge on attached VM.
