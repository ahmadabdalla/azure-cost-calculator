# Virtual Machines

**Primary cost**: Compute hours (hourly rate × 730)

> **Trap (verified 2026-02-06)**: A query with only `-ArmSkuName` and no other filters returns **6 results**: Linux standard, Windows standard, Linux Spot, Windows Spot, Linux Low Priority, and Windows Low Priority. The `summary.totalMonthlyCost` sums all 6, inflating the estimate ~5×+. Always identify the correct row by checking `productName` (no "Windows" = Linux) and `skuName` (no "Spot"/"Low Priority" suffix = standard pay-as-you-go).

## Query Pattern

```powershell
.\Get-AzurePricing.ps1 `
    -ServiceName 'Virtual Machines' `
    -ArmSkuName 'Standard_D2s_v5'
```

## Key Fields

| Parameter     | How to determine                            | Example values                                                                 |
| ------------- | ------------------------------------------- | ------------------------------------------------------------------------------ |
| `armSkuName`  | VM size from portal/Bicep `vmSize` property | `Standard_D2s_v5`, `Standard_B2ms`, `Standard_E4s_v5`                          |
| `productName` | Contains series + OS indicator              | `Virtual Machines Dsv5 Series` (Linux), `Virtual Machines Dsv5 Series Windows` |

## Filter Tips

- Linux: `productName` does NOT contain "Windows"
- Windows: `productName` contains "Windows"
- Spot: `skuName` ends with "Spot"
- Low Priority: `skuName` ends with "Low Priority"
- Reservations: set `-PriceType Reservation` — `reservationTerm` will show "1 Year" or "3 Years"

> **Trap (RI MonthlyCost — verified 2026-02-06)**: For `-PriceType Reservation`, the API returns a **total term price** (e.g., £1,120 for the full year), NOT an hourly rate. The script still multiplies by 730 hours, producing an absurdly inflated `MonthlyCost` (e.g., £817K). **Always ignore the script's `MonthlyCost`** for Reservation items and manually calculate: `unitPrice ÷ 12` for monthly cost, or use `unitPrice` directly as the annual cost.

## Cost Formula

```
Monthly = retailPrice × 730 hours × instanceCount
```

## Common VM SKUs (armSkuName)

| Size              | vCPUs | RAM (GB) | Typical use           |
| ----------------- | ----- | -------- | --------------------- |
| `Standard_B2ms`   | 2     | 8        | Dev/test, low traffic |
| `Standard_D2s_v5` | 2     | 8        | General purpose       |
| `Standard_D4s_v5` | 4     | 16       | General purpose       |
| `Standard_D8s_v5` | 8     | 32       | General purpose       |
| `Standard_E2s_v5` | 2     | 16       | Memory optimized      |
| `Standard_E4s_v5` | 4     | 32       | Memory optimized      |
| `Standard_F2s_v2` | 2     | 4        | Compute optimized     |
