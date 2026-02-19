---
serviceName: Storage
category: storage
aliases: [managed disks, disks, disk storage]
billingConsiderations: [Reserved Instances]
primaryCost: "Fixed monthly rate per disk (+ mount fee for Premium/Standard SSD)"
privateEndpoint: true
---

# Managed Disks

> **Warning (Premium/Standard SSD two-meter trap)**: The API returns **both** "Disk" **and** "Disk Mount" meters. **You MUST sum both** — the mount fee alone is ~5% of cost. Using only mount fee = **~20× too cheap**. Always use `summary.totalMonthlyCost` which sums correctly. Premium SSD returns 2 meters, Standard SSD returns 3 (+ Operations), Standard HDD returns 2 (Disk + Operations, no mount fee).

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

## Expected API Response (Premium SSD)

P30 LRS returns **2 rows** — both required: `P30 LRS Disk` (~95% of cost) + `P30 LRS Disk Mount` (~5%). **Mount fee alone = ~20× underestimate**.

## Meters per Disk Type

| Disk Type      |                           Disk                           | Disk Mount | Disk Operations |
| -------------- | :------------------------------------------------------: | :--------: | :-------------: |
| Premium SSD    |                           YES                            |    YES     |       NO        |
| Standard SSD   |                           YES                            |    YES     |  YES (per 10K)  |
| Standard HDD   |                           YES                            |     NO     |  YES (per 10K)  |
| Ultra Disk     | Provisioned Capacity, IOPS, Throughput, vCPU Reservation |     —      |        —        |
| Premium SSD v2 |          Provisioned Capacity, IOPS, Throughput          |     —      |        —        |

> **Trap (Premium SSD v2)**: API returns two rows each for IOPS and Throughput — one at zero (free tier), one at paid rate. Use non-zero `retailPrice` and subtract: `max(0, IOPS - 3000)`, `max(0, MBps - 125)`.
> **Trap (Ultra vCPU)**: Ultra Disk has 4th meter `Ultra LRS Reservation per vCPU Provisioned` — per vCPU on attached VM.

## Key Fields

| Parameter     | Example values                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------ |
| `productName` | `Premium SSD Managed Disks`, `Standard SSD Managed Disks`, `Ultra Disks`, `Azure Premium SSD v2` |
| `skuName`     | `P30 LRS`, `P30 ZRS`, `E30 LRS`, `S30 LRS`, `Ultra LRS`, `Premium LRS`                           |
| `meterName`   | `P30 LRS Disk`, `P30 LRS Disk Mount`, `E30 LRS Disk Operations`                                  |

## Cost Formula

- **Premium SSD**: `Monthly = (diskPrice + mountFee) × diskCount`
- **Standard SSD**: `Monthly = (diskPrice + mountFee + txnOps/10000 × opsPrice) × diskCount`
- **Standard HDD**: `Monthly = (diskPrice + txnOps/10000 × opsPrice) × diskCount`
- **Ultra Disk**: `Monthly = (GiB × capacityPrice + IOPS × iopsPrice + MBps × tputPrice + vCPUs × vcpuPrice) × 730`
- **Premium SSD v2**: `Monthly = (GiB × capacityPrice + max(0, IOPS - 3000) × iopsPrice + max(0, MBps - 125) × tputPrice) × 730`

## Notes

- Deallocating a VM does **NOT** stop disk billing — disks billed per-disk, per-month.
- Premium SSD P1–P20 include free burst (on-demand burst P20+ separate meter); snapshots billed separately
- Private endpoints limited to disk import/export operations

## Reserved Instance Pricing

Available for **Premium SSD only** (1-year). Query with `-PriceType Reservation`.

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
