---
serviceName: Virtual Machines
category: compute
aliases: [VMs, Azure VMs, IaaS VMs, VM Scale Sets, VMSS, Dedicated Host]
billingNeeds: [Managed Disks]
billingConsiderations: [Reserved Instances, Spot Pricing, Azure Hybrid Benefit]
primaryCost: "Compute hours (hourly rate × 730 × instanceCount)"
---

# Virtual Machines

> **Trap**: A query with only `ArmSkuName` and no `ProductName` filter returns **multiple results** (up to 6 for v5: Linux/Windows × Standard/Spot/Low Priority; fewer for most v6+ series). Without `ProductName`, the cheapest row may be selected, underestimating by ~5×. **Always include `ProductName`** in every VM query.

## Query Pattern

### Linux standard (ProductName is mandatory)

ServiceName: Virtual Machines
ArmSkuName: Standard_D2s_v5
ProductName: Virtual Machines Dsv5 Series

### Windows standard only

ServiceName: Virtual Machines
ArmSkuName: Standard_D2s_v5
ProductName: Virtual Machines Dsv5 Series Windows

> **Note**: Pattern is `'Virtual Machines {Series} Series'` (Linux) or `'… Series Windows'` for v4–v6. **v7 Intel uses a different pattern**: `'Virtual Machines {Series}-series Linux'` or `'…-series Windows'` (hyphen, lowercase `series`, explicit OS suffix). v7 AMD keeps the standard pattern. **Casing rule**: v4+ series use lowercase `s` (`Dsv5`, `Esv5`, `Dsv6`). Pre-v4 series where `S` meant premium SSD keep the **capital S**: `FSv2`, `FS`, `DSv2`, `DSv3`, `DS`, `ESv3`, `BS`, `GS`, `LS`, `LSv2`, `MS`, `MSv2`, `MdSv2`, `HBSv2`, `HBS`, `HCS`, `NDrSv2`. When unsure, use the explore script with ServiceName `Virtual Machines` and SearchTerm `{series}` to confirm exact casing before querying.

## Key Fields

| Parameter     | How to determine                            | Example values                                                                 |
| ------------- | ------------------------------------------- | ------------------------------------------------------------------------------ |
| `serviceName` | Always `Virtual Machines`                   | `Virtual Machines`                                                             |
| `armSkuName`  | VM size from portal/Bicep `vmSize` property | `Standard_D2s_v5`, `Standard_B2ms`, `Standard_E4s_v5`                          |
| `productName` | Contains series + OS indicator              | `Virtual Machines Dsv5 Series` (Linux), `Virtual Machines Dsv5 Series Windows`, `Virtual Machines Dsv7-series Linux` (v7 Intel) |
| `skuName`     | Size + pricing tier suffix                  | `D2s v5`, `D2s v5 Spot`, `D2s v5 Low Priority`                                 |

## Meter Names

| Meter                      | unitOfMeasure | Notes                                                                 |
| -------------------------- | ------------- | --------------------------------------------------------------------- |
| _(VM size, e.g. `D2s v5`)_ | `1 Hour`      | Meter name mirrors ARM SKU without `Standard_` prefix and underscores |

## Cost Formula

```
Monthly = retailPrice × 730 hours × instanceCount
```

## Notes

- Use the explore script with ServiceName `Virtual Machines` and SearchTerm `{series}` to discover exact `productName` values
- **VMSS**: Scale-set instances use the same `serviceName` and VM compute meters as standalone VMs. There is no _additional_ VMSS/orchestration meter; you still calculate **compute** as `retailPrice × 730 × instanceCount`, and price managed disks and any attached resources (load balancer, public IP, etc.) separately. Flexible and Uniform orchestration modes have no pricing difference.
- **Spot VMs**: market-priced, can be evicted at any time; query by picking the row where `skuName` ends with `Spot`. Low Priority VMs follow the same pattern (`Low Priority` suffix) but availability varies — most v6+ Intel series lack Low Priority (Spot only), while some AMD v6 series (e.g., Dadsv6) still offer it

## Azure Hybrid Benefit (AHUB)

For AHUB VMs, query the **Linux** `productName` (no "Windows" suffix). The Linux rate IS the AHUB rate. There is no separate "Base Compute" or AHUB-specific `productName` for VMs. Do not query Windows and manually discount. Always confirm AHUB eligibility with the user first.

### AHUB for Windows E16s v5 (example, queries Linux rate)

ServiceName: Virtual Machines
ArmSkuName: Standard_E16s_v5
ProductName: Virtual Machines Esv5 Series
InstanceCount: 15

## Reserved Instance Pricing

### RI for Linux D2s v5 (returns both 1-Year and 3-Year terms)

ServiceName: Virtual Machines
ArmSkuName: Standard_D2s_v5
ProductName: Virtual Machines Dsv5 Series
PriceType: Reservation

## Common SKUs

| SKU               | vCPUs | RAM (GB) | Tier/Notes            |
| ----------------- | ----- | -------- | --------------------- |
| `Standard_B2ms`   | 2     | 8        | Dev/test, low traffic |
| `Standard_D2s_v5` | 2     | 8        | General purpose       |
| `Standard_D4s_v5` | 4     | 16       | General purpose       |
| `Standard_D8s_v5` | 8     | 32       | General purpose       |
| `Standard_D2s_v6` | 2     | 8        | General purpose (v6)  |
| `Standard_D4s_v6` | 4     | 16       | General purpose (v6)  |
| `Standard_E2s_v5` | 2     | 16       | Memory optimized      |
| `Standard_E4s_v5` | 4     | 32       | Memory optimized      |
| `Standard_F2s_v2` | 2     | 4        | Compute optimized     |
