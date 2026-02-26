---
serviceName: Azure NetApp Files
category: storage
aliases: [NetApp, ANF, Azure NetApp]
billingConsiderations: [Reserved Instances]
primaryCost: "Provisioned capacity pool per-GiB/hour × 730 by performance tier + backup per-GiB/month"
hasKnownRates: true
---

# Azure NetApp Files

> **Trap (MonthlyCost zero)**: Capacity meters use `1 GiB/Hour` which the script does not recognize as hourly — `MonthlyCost` shows zero. Calculate manually: `retailPrice × provisionedGiB × 730`. See Known Rates.
>
> **Agent instruction**: Do NOT report zero cost. Multiply `retailPrice × GiB × 730` for monthly capacity cost.

> **Trap (Unfiltered Query)**: `ServiceName`-only query returns all tiers, backup, CRR, and cool-access meters — always filter by `SkuName` + `MeterName`.

## Query Pattern

### Standard tier capacity pool (default)

ServiceName: Azure NetApp Files
ProductName: Azure NetApp Files
SkuName: Standard
MeterName: Standard Capacity

### Premium tier (Quantity = provisioned GiB)

ServiceName: Azure NetApp Files
ProductName: Azure NetApp Files
SkuName: Premium
MeterName: Premium Capacity
Quantity: 2048

### Backup storage

ServiceName: Azure NetApp Files
ProductName: Azure NetApp Files
SkuName: Backup
MeterName: Backup Capacity

## Key Fields

| Parameter     | How to determine                | Example values                                               |
| ------------- | ------------------------------- | ------------------------------------------------------------ |
| `serviceName` | Always `Azure NetApp Files`     | `Azure NetApp Files`                                         |
| `productName` | Consumption vs Reserved         | `Azure NetApp Files`, `Azure NetApp Files Reserved Capacity` |
| `skuName`     | Performance tier (never-assume) | `Standard`, `Premium`, `Ultra`, `Backup`                     |
| `meterName`   | `{Tier} Capacity`               | `Standard Capacity`, `Premium Capacity`, `Ultra Capacity`    |

## Meter Names

| Meter | skuName | unitOfMeasure | Notes |
| ----- | ------- | ------------- | ----- |
| `Standard Capacity` | `Standard` | `1 GiB/Hour` | × 730 for monthly |
| `Premium Capacity` | `Premium` | `1 GiB/Hour` | × 730 for monthly |
| `Ultra Capacity` | `Ultra` | `1 GiB/Hour` | × 730 for monthly |
| `Backup Capacity` | `Backup` | `1 GiB/Month` | No × 730 needed |
| `Volume Restore Capacity` | `Volume Restore` | `1 GiB` | One-time per restore |
| `Standard Storage with Cool Access Capacity` | `Standard Storage with Cool Access` | `1 GiB/Hour` | Cool tier at-rest |
| `Flexible Service Level Capacity` | `Flexible Service Level` | `1 GiB/Hour` | Capacity component |
| `Flexible Service Level Throughput MiBps` | `Flexible Service Level` | `1/Hour` | Beyond 128 MiBps free |

## Cost Formula

```
Capacity: Monthly = retailPrice × provisionedGiB × 730
Backup:   Monthly = backup_retailPrice × backupGiB
Flexible: Monthly = capacity_price × GiB × 730 + max(0, MiBps - 128) × throughput_price × 730
```

## Notes

- Billing is on **provisioned capacity pool size**, not consumed — minimum 1 TiB, increments of 1 TiB
- Snapshots consume pool capacity — no separate meter; billed at the pool's tier rate
- Standard/Premium/Ultra differ in throughput/IOPS limits; tier is a never-assume parameter
- Double Encrypted variants: `SkuName: {Tier} Double Encrypted` (~19% surcharge)
- CRR meters are region-pair-specific with Days/Hours/Minutes replication frequency tiers
- Network isolation uses **delegated subnets** (`Microsoft.NetApp/volumes`), not Private Link — no PE support

## Known Rates

| Meter | Unit | Published Rate (USD) | Monthly per GiB |
| ----- | ---- | -------------------- | --------------- |
| `Standard Capacity` | 1 GiB/Hour | $0.000202 | ~$0.15 |
| `Premium Capacity` | 1 GiB/Hour | $0.000403 | ~$0.29 |
| `Ultra Capacity` | 1 GiB/Hour | $0.000538 | ~$0.39 |
| `Backup Capacity` | 1 GiB/Month | $0.05 | $0.05 |

> These rates are from the Azure Retail Prices API (eastus). The script shows `$0.00` for capacity meters because `1 GiB/Hour` is not recognized as hourly. Multiply `retailPrice × GiB × 730` manually. For non-USD currencies, see [regions-and-currencies.md](../../regions-and-currencies.md).

## Reserved Instance Pricing

Available for Standard/Premium/Ultra at 100 TiB or 1 PiB commitment levels (1-Year and 3-Year terms). Single encryption only — not available for Double Encrypted tiers.

ServiceName: Azure NetApp Files
ProductName: Azure NetApp Files Reserved Capacity
SkuName: Standard - 100 TiB
PriceType: Reservation
