````markdown
# Container Registry (ACR)

**Primary cost**: Registry unit (daily) + excess storage (per-GB/month)

> **Critical trap**: Registry Unit meters are priced **per day** (`1/Day` unit), NOT per hour. Multiplying by 730 gives a result ~24× too high. Always multiply by **30** (days/month).
> **Trap (verified 2026-02-06)**: The script's auto-calculated `MonthlyCost` is **wrong** for this service. Because the unit is `1/Day`, the script reports only the daily price (e.g., `$2.38`) instead of the correct monthly cost (`$2.38 × 30 = $71.44`). **Always ignore the script's `MonthlyCost`** and manually calculate: `unitPrice × 30`.
>
> **Agent instruction**: When reporting ACR costs, always check the `unitOfMeasure` field. If it's `1/Day`, multiply by 30 (not 730). Never trust the script's `MonthlyCost` for this service.

## Query Pattern

```powershell
# Premium tier — registry unit (daily cost)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Container Registry' `
    -ProductName 'Container Registry' `
    -MeterName 'Premium Registry Unit'

# Basic tier — registry unit
.\Get-AzurePricing.ps1 `
    -ServiceName 'Container Registry' `
    -ProductName 'Container Registry' `
    -MeterName 'Basic Registry Unit'

# Standard tier — registry unit
.\Get-AzurePricing.ps1 `
    -ServiceName 'Container Registry' `
    -ProductName 'Container Registry' `
    -MeterName 'Standard Registry Unit'

# Data stored (excess storage beyond included quota)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Container Registry' `
    -ProductName 'Container Registry' `
    -MeterName 'Data Stored'

# Geo-replication storage (Premium only)
.\Get-AzurePricing.ps1 `
    -ServiceName 'Container Registry' `
    -ProductName 'Container Registry' `
    -MeterName 'Premium GB Registry Replication Data Stored'
```

## Meter Names (case-sensitive)

| Meter                                         | unitOfMeasure | Notes                          |
| --------------------------------------------- | ------------- | ------------------------------ |
| `Basic Registry Unit`                         | `1/Day`       | Basic tier registry            |
| `Standard Registry Unit`                      | `1/Day`       | Standard tier registry         |
| `Premium Registry Unit`                       | `1/Day`       | Premium tier registry          |
| `Data Stored`                                 | `1 GB/Month`  | Excess storage beyond included |
| `Premium GB Registry Replication Data Stored` | `1 GB/Month`  | Per-replica geo-replication    |

## Included Storage by Tier

| Tier     | Included Storage |
| -------- | ---------------- |
| Basic    | 10 GB            |
| Standard | 100 GB           |
| Premium  | 500 GB           |

## Cost Formula

```
Monthly = registryUnitPrice × 30 + storagePrice × max(0, totalGB - includedGB)
```

> **Remember**: Use `× 30` (days), NOT `× 730` (hours). Check `unitOfMeasure` in the API response.

## Example (Premium, verified 2026-02-06)

```
Registry: registryUnitPrice × 30
Storage (50 GB excess): storagePrice × max(0, totalGB - includedGB)
Total: sum of above — query live prices for current rates
```

## Notes

- Premium tier is required for geo-replication, content trust, and private endpoints
- Build tasks (ACR Tasks) have separate compute-based pricing not covered here
- Networking: Premium supports private link; Basic/Standard are public only
````
