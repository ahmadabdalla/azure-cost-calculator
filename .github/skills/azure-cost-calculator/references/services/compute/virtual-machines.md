# Virtual Machines

**Primary cost**: Compute hours (hourly rate × 730)

> **Trap**: A query with only `-ArmSkuName` and no other filters returns **6 results**: Linux standard, Windows standard, Linux Spot, Windows Spot, Linux Low Priority, and Windows Low Priority. The `summary.totalMonthlyCost` sums all 6, inflating the estimate ~5×+. Always identify the correct row by checking `productName` (no "Windows" = Linux) and `skuName` (no "Spot"/"Low Priority" suffix = standard pay-as-you-go).

## Query Pattern

```powershell
# Recommended: Filter to Linux standard only using -ProductName
.\Get-AzurePricing.ps1 `
    -ServiceName 'Virtual Machines' `
    -ArmSkuName 'Standard_D2s_v5' `
    -ProductName 'Virtual Machines Dsv5 Series'

# Windows standard only
.\Get-AzurePricing.ps1 `
    -ServiceName 'Virtual Machines' `
    -ArmSkuName 'Standard_D2s_v5' `
    -ProductName 'Virtual Machines Dsv5 Series Windows'
```

> **Tip (productName pattern)**: Pattern is `'Virtual Machines {Series} Series'` (Linux) or `'… Series Windows'`. Series name drops underscores/casing from ARM SKU: `Standard_D2s_v5` → `Dsv5`, `Standard_B2ms` → `Bms`. Use `Explore-AzurePricing.ps1 -ServiceName 'Virtual Machines' -SearchTerm '{series}'` to discover exact values.

## Key Fields

| Parameter     | How to determine                            | Example values                                                                 |
| ------------- | ------------------------------------------- | ------------------------------------------------------------------------------ |
| `serviceName` | Always `Virtual Machines`                   | `Virtual Machines`                                                             |
| `armSkuName`  | VM size from portal/Bicep `vmSize` property | `Standard_D2s_v5`, `Standard_B2ms`, `Standard_E4s_v5`                          |
| `productName` | Contains series + OS indicator              | `Virtual Machines Dsv5 Series` (Linux), `Virtual Machines Dsv5 Series Windows` |
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

- Node VMs (e.g., AKS, Batch) are priced as Virtual Machines
- Use `Explore-AzurePricing.ps1 -ServiceName 'Virtual Machines' -SearchTerm '{series}'` to discover exact `productName` values

## Reserved Instance Pricing

```powershell
# RI for Linux D2s v5 (returns both 1-Year and 3-Year terms)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Virtual Machines' `
    -ArmSkuName 'Standard_D2s_v5' `
    -ProductName 'Virtual Machines Dsv5 Series' `
    -PriceType Reservation
```

> **Trap (RI MonthlyCost)**: See [pitfalls.md](../pitfalls.md). Manually calculate: `unitPrice ÷ 12` (1-Year) or `÷ 36` (3-Year). Select desired `reservationTerm` ("1 Year" / "3 Years") from results.

## Common SKUs

| SKU               | vCPUs | RAM (GB) | Tier/Notes            |
| ----------------- | ----- | -------- | --------------------- |
| `Standard_B2ms`   | 2     | 8        | Dev/test, low traffic |
| `Standard_D2s_v5` | 2     | 8        | General purpose       |
| `Standard_D4s_v5` | 4     | 16       | General purpose       |
| `Standard_D8s_v5` | 8     | 32       | General purpose       |
| `Standard_E2s_v5` | 2     | 16       | Memory optimized      |
| `Standard_E4s_v5` | 4     | 32       | Memory optimized      |
| `Standard_F2s_v2` | 2     | 4        | Compute optimized     |
