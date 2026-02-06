````markdown
# Managed Disks

**Primary cost**: Fixed monthly rate per disk + disk mount fee

> **Trap**: Each disk SKU returns **two meters** — `{Size} {Red} Disk` (main cost) and `{Size} {Red} Disk Mount` (smaller mount fee). The `summary.totalMonthlyCost` sums both, which is correct — but present them separately for transparency.

## Disk Types

| Disk Type      | productName                  | SKU Prefix | Use Case                                |
| -------------- | ---------------------------- | ---------- | --------------------------------------- |
| Premium SSD    | `Premium SSD Managed Disks`  | `P`        | Production workloads, high IOPS         |
| Standard SSD   | `Standard SSD Managed Disks` | `E`        | Web servers, dev/test, light production |
| Standard HDD   | `Standard HDD Managed Disks` | `S`        | Backups, infrequent access              |
| Ultra Disk     | `Ultra Disks`                | N/A        | IO-intensive (SAP HANA, databases)      |
| Premium SSD v2 | `Azure Premium SSD v2`       | N/A        | Flexible IOPS/throughput tuning         |

## Query Pattern

```powershell
# Fixed-size disks — substitute {Prefix}, {Size}, {productName} from Disk Types table
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName '{Prefix}{Size} LRS' -ProductName '{productName}'
# Add -MeterName '{Prefix}{Size} LRS Disk' to isolate disk cost from mount fee
# ZRS: -SkuName '{Prefix}{Size} ZRS' (Premium/Standard SSD only, ~50% more). HDD is LRS only.

# Provisioned disks (Ultra / Premium SSD v2) — query each meter separately:
#   -MeterName '{sku} LRS Provisioned Capacity'
#   -MeterName '{sku} LRS Provisioned IOPS'
#   -MeterName '{sku} LRS Provisioned Throughput (MBps)'
# Ultra: -SkuName 'Ultra LRS' -ProductName 'Ultra Disks'
# PremiumV2: -SkuName 'Premium LRS' -ProductName 'Azure Premium SSD v2' (includes 3K IOPS + 125 MBps free)
```

> Standard SSD/HDD return an additional `Disk Operations` meter (per 10K IO). Premium SSD does NOT — IOPS included in price.

## Key Fields

| Parameter     | How to determine           | Example values                                                           |
| ------------- | -------------------------- | ------------------------------------------------------------------------ |
| `productName` | Disk type — case-sensitive | `Premium SSD Managed Disks`, `Standard SSD Managed Disks`, `Ultra Disks` |
| `skuName`     | Disk size + redundancy     | `P30 LRS`, `P30 ZRS`, `E30 LRS`, `S30 LRS`, `Ultra LRS`                  |
| `meterName`   | Specific cost component    | `P30 LRS Disk`, `P30 LRS Disk Mount`, `E30 LRS Disk Operations`          |

## Cost Formula

**Fixed-size disks**: `Monthly = diskPrice + mountFee + (txnOps/10000 × opsPrice)`

**Provisioned** (Ultra / Premium SSD v2): `Monthly = (GiB × capacityPrice + IOPS × iopsPrice + MBps × tputPrice) × 730`

## Reserved Instance Pricing

Available for **Premium SSD only** (1-year). Query with `-PriceType Reservation`.

> **Trap (RI MonthlyCost)**: See [pitfalls.md](../pitfalls.md). Calculate: unitPrice ÷ 12 for monthly cost.

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
````
