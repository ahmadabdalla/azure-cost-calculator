# Virtual Machines

**Primary cost**: Compute hours (hourly rate × 730)

> **Trap**: A query with only `-ArmSkuName` and no other filters returns **6 results**: Linux standard, Windows standard, Linux Spot, Windows Spot, Linux Low Priority, and Windows Low Priority. The `summary.totalMonthlyCost` sums all 6, inflating the estimate ~5×+. Always identify the correct row by checking `productName` (no "Windows" = Linux) and `skuName` (no "Spot"/"Low Priority" suffix = standard pay-as-you-go).

## Query Pattern

```powershell
# Unfiltered — returns 6 results (Linux + Windows × Standard + Spot + Low Priority)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Virtual Machines' `
    -ArmSkuName 'Standard_D2s_v5'

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

> **Tip (productName pattern)**: The `productName` follows the pattern `'Virtual Machines {Series} Series'` for **Linux** and `'Virtual Machines {Series} Series Windows'` for **Windows**. Using `-ProductName` reduces results from 6 to 3 (Standard + Spot + Low Priority for one OS). The series name in `productName` drops underscores and 'v' casing from the ARM SKU — e.g., `Standard_D2s_v5` → series `Dsv5`, `Standard_E4s_v5` → series `Esv5`, `Standard_B2ms` → series `Bms`. When in doubt, run `Explore-AzurePricing.ps1 -ServiceName 'Virtual Machines' -SearchTerm '{series}'` to discover the exact `productName`.

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

- Linux: `productName` does NOT contain "Windows"
- Windows: `productName` contains "Windows"
- Spot: `skuName` ends with "Spot"
- Low Priority: `skuName` ends with "Low Priority"
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

> **Trap (RI MonthlyCost)**: For `-PriceType Reservation`, the API returns a **total term price** (e.g., £1,120 for the full year), NOT an hourly rate. The script still multiplies by 730 hours, producing an absurdly inflated `MonthlyCost` (e.g., £817K). **Always ignore the script's `MonthlyCost`** for Reservation items and manually calculate: `unitPrice ÷ 12` for monthly cost, or use `unitPrice` directly as the annual cost.
>
> **Agent instruction**: `reservationTerm` will show "1 Year" or "3 Years" — select the desired term from results.

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
