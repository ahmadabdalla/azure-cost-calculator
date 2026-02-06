````markdown
# Managed Disks

**Primary cost**: Fixed monthly rate per disk + disk mount fee

> **Trap (verified 2026-02-06)**: Each disk SKU returns **two meters** — `{Size} {Red} Disk` (main cost) and `{Size} {Red} Disk Mount` (smaller mount fee). The `summary.totalMonthlyCost` sums both, which is correct — but present them separately for transparency.

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
# Premium SSD — P30 LRS (returns disk + mount meters)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'P30 LRS' `
    -ProductName 'Premium SSD Managed Disks'

# Standard SSD — E30 LRS
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'E30 LRS' `
    -ProductName 'Standard SSD Managed Disks' `
    -MeterName 'E30 LRS Disk'

# Standard HDD — S30 LRS
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' `
    -SkuName 'S30 LRS' `
    -ProductName 'Standard HDD Managed Disks' `
    -MeterName 'S30 LRS Disk'
```

> **Note**: Standard SSD returns a third meter `{Size} LRS Disk Operations` (per 10K IO ops). Standard HDD also has a `Disk Operations` meter. Premium SSD does NOT — IOPS are included in the disk price.

> **Note**: Standard HDD is **LRS only** — no ZRS option. Premium SSD and Standard SSD support both LRS and ZRS (ZRS ~50% more). Use `-SkuName '{Size} ZRS'` for zone-redundant pricing.

### Ultra Disk & Premium SSD v2 (provisioned)

These use three hourly meters instead of fixed monthly pricing:

```powershell
# Ultra Disk
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Ultra LRS' -ProductName 'Ultra Disks' -MeterName 'Ultra LRS Provisioned Capacity'
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Ultra LRS' -ProductName 'Ultra Disks' -MeterName 'Ultra LRS Provisioned IOPS'
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Ultra LRS' -ProductName 'Ultra Disks' -MeterName 'Ultra LRS Provisioned Throughput (MBps)'

# Premium SSD v2 (includes 3,000 IOPS and 125 MBps free)
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Premium LRS' -ProductName 'Azure Premium SSD v2' -MeterName 'Premium LRS Provisioned Capacity'
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Premium LRS' -ProductName 'Azure Premium SSD v2' -MeterName 'Premium LRS Provisioned IOPS'
.\Get-AzurePricing.ps1 -ServiceName 'Storage' -SkuName 'Premium LRS' -ProductName 'Azure Premium SSD v2' -MeterName 'Premium LRS Provisioned Throughput (MBps)'
```

## Key Fields

| Parameter     | How to determine           | Example values                                                           |
| ------------- | -------------------------- | ------------------------------------------------------------------------ |
| `productName` | Disk type — case-sensitive | `Premium SSD Managed Disks`, `Standard SSD Managed Disks`, `Ultra Disks` |
| `skuName`     | Disk size + redundancy     | `P30 LRS`, `P30 ZRS`, `E30 LRS`, `S30 LRS`, `Ultra LRS`                  |
| `meterName`   | Specific cost component    | `P30 LRS Disk`, `P30 LRS Disk Mount`, `E30 LRS Disk Operations`          |

## Cost Formula

**Fixed-size disks** (Premium/Standard SSD/HDD):

```
Monthly = diskPrice + mountFee + (transactionOps/10000 × opsPrice)
```

**Provisioned disks** (Ultra / Premium SSD v2):

```
Monthly = (capacityGiB × capacityPrice × 730) + (IOPS × iopsPrice × 730) + (MBps × throughputPrice × 730)
```

## Reserved Instance Pricing

Available for **Premium SSD only** (1-year term).

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Storage' -SkuName 'P30 LRS' `
    -ProductName 'Premium SSD Managed Disks' -MeterName 'P30 LRS Disk' `
    -PriceType Reservation
```

> **Trap (RI pricing — verified 2026-02-06)**: The API returns the **total annual prepaid price** (e.g., $1,541 USD for P30 LRS). Divide by 12 for monthly cost: `$1,541 ÷ 12 ≈ $128.42/month` — ~5% saving vs pay-as-you-go.

## Common SKUs

| Prefix | SKU   | Size (GiB) | Max IOPS | Max MBps | Typical Use          |
| ------ | ----- | ---------- | -------- | -------- | -------------------- |
| P      | `P4`  | 32         | 120      | 25       | Small OS disks       |
| P      | `P6`  | 64         | 240      | 50       | Light workloads      |
| P      | `P10` | 128        | 500      | 100      | Dev/test             |
| P      | `P20` | 512        | 2,300    | 150      | Medium workloads     |
| P      | `P30` | 1,024      | 5,000    | 200      | Production databases |
| P      | `P40` | 2,048      | 7,500    | 250      | Large databases      |
| P      | `P50` | 4,096      | 7,500    | 250      | Data warehouses      |
| E      | `E10` | 128        | —        | —        | Dev/test             |
| E      | `E20` | 512        | —        | —        | Medium workloads     |
| E      | `E30` | 1,024      | —        | —        | General purpose      |
| S      | `S10` | 128        | —        | —        | Dev/test backups     |
| S      | `S20` | 512        | —        | —        | Backup storage       |
| S      | `S30` | 1,024      | —        | —        | Archive storage      |

> All three types share the same size tiers (4/6/10/15/20/30/40/50/60/70/80). Only the most common are listed above.

## Notes

- Disk pricing is per-disk, per-month. Deallocating a VM does **NOT** stop disk billing.
- Premium SSD P1–P20 include free burst (up to 3,500 IOPS / 170 MBps). On-demand burst for P20+ is a separate meter.
- Disk snapshots are billed separately under `Managed Disk Snapshots` productName.
- Ultra Disks and Premium SSD v2 have a per-vCPU reservation charge for the attached VM.
````
